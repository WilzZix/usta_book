# Push Notifications Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add FCM-based push notifications for masters: per-appointment reminders (1h + 15m before) and a daily summary at a master-chosen time.

**Architecture:** Reuse the existing SMS queue + scheduled-poller pattern. New `push_queue` Firestore collection populated by appointment triggers; `sendPushReminders` polls every minute. Daily summaries are not enqueued — `sendDailySummaries` runs every 15 minutes and matches masters by local time, with idempotency markers. Flutter side uses `firebase_messaging` + `flutter_local_notifications`; settings live under Profile.

**Tech Stack:** TypeScript (Cloud Functions, Jest), Dart/Flutter (firebase_messaging ^15, flutter_local_notifications ^17, flutter_bloc, GetIt/injectable), Firestore.

**Spec:** `docs/superpowers/specs/2026-05-03-push-notifications-design.md`

---

## File Structure

### Cloud Functions (TypeScript)

| Path | Action | Responsibility |
|------|--------|----------------|
| `functions/src/types.ts` | Modify | Add `PushKind`, `PushPayloadKind`, `PushStatus`, `PushQueueDoc`, `FcmToken`, `PushSettings`, `FcmPayload` |
| `functions/src/services/pushTemplates.ts` | Create | Pure payload builders + `pluralizeRu` |
| `functions/src/services/fcmService.ts` | Create | `sendPushToMaster(masterUID, payload)` — fetches tokens, sends multicast, prunes invalid |
| `functions/src/triggers/onAppointmentCreated.ts` | Modify | Add `buildPushQueueDocs()` + queue writes alongside SMS |
| `functions/src/triggers/onAppointmentDeleted.ts` | Modify | Delete push queue docs alongside SMS docs |
| `functions/src/triggers/onAppointmentUpdated.ts` | Create | Re-enqueue when `dateTime` changes |
| `functions/src/scheduled/sendPushReminders.ts` | Create | Every-minute poller for `push_queue` |
| `functions/src/scheduled/sendDailySummaries.ts` | Create | Every-15m matcher for daily summaries |
| `functions/src/index.ts` | Modify | Export new triggers + scheduled functions |
| `functions/src/__tests__/*.test.ts` | Create/extend | Unit tests for pure functions |

### Flutter (Dart)

| Path | Action | Responsibility |
|------|--------|----------------|
| `pubspec.yaml` | Modify | Add `firebase_messaging`, `flutter_local_notifications`, `app_settings` |
| `lib/data/models/push_settings.dart` | Create | Model + `fromMap`/`toMap` |
| `lib/domain/repositories/push_settings/push_settings_repository.dart` | Create | Abstract interface |
| `lib/data/repositories/push_settings/push_settings_repository_impl.dart` | Create | Firestore-backed impl |
| `lib/data/sources/firebase/push_notification_service.dart` | Create | FCM init, permission, token registration, foreground handler, navigation |
| `lib/bloc/push_settings/push_settings_cubit.dart` | Create | Stream `pushSettings`; toggle/setTime |
| `lib/bloc/push_settings/push_settings_state.dart` | Create | States |
| `lib/presentation/profile/notification_settings_screen.dart` | Create | UI: toggles + time picker + permission banner |
| `lib/presentation/profile/profile_page.dart` | Modify | Wire "Notifications" `ProfileItem.onTap` |
| `lib/presentation/home/home_page.dart` (or equivalent) | Modify | Request permission on first entry |
| `lib/data/sources/local/shared_pref.dart` | Modify | Add `pushOnboarded` key methods |
| `lib/bloc/auth/auth_cubit.dart` | Modify | Delete FCM token on logout |
| `lib/main.dart` | Modify | Init `PushNotificationService`, register background handler, register cubit, expose `GoRouter` globally |
| `lib/core/localization/i18n/strings_*.i18n.json` | Modify | Add notification settings strings (uz, ru) |
| `lib/firebase_messaging_background_handler.dart` | Create | Top-level `@pragma('vm:entry-point')` background handler |

---

## Task 1: Add Cloud Functions types

**Files:**
- Modify: `functions/src/types.ts`

- [ ] **Step 1: Add new types to `types.ts`**

Append to the bottom of `functions/src/types.ts`:

```ts
// Queue-only kinds (daily summary is not enqueued)
export type PushKind = 'reminder_1h' | 'reminder_15m';

// Kinds carried in the FCM data payload (broader than queue)
export type PushPayloadKind = PushKind | 'daily_summary';

export type PushStatus = 'pending' | 'sent' | 'failed' | 'cancelled';

export interface PushQueueDoc {
  appointmentId: string;
  masterUID: string;
  kind: PushKind;
  sendAt: Timestamp;
  status: PushStatus;
  language: Language;
  error: string | null;
}

export interface FcmToken {
  token: string;
  platform: 'ios' | 'android';
  createdAt: Timestamp;
  lastSeenAt: Timestamp;
}

export interface PushSettings {
  reminderOneHour: boolean;
  reminderFifteenMin: boolean;
  dailySummary: boolean;
  dailySummaryTime: string; // 'HH:MM'
  timezone: string;         // IANA, e.g. 'Asia/Tashkent'
}

export const DEFAULT_PUSH_SETTINGS: PushSettings = {
  reminderOneHour: true,
  reminderFifteenMin: true,
  dailySummary: true,
  dailySummaryTime: '08:00',
  timezone: 'Asia/Tashkent',
};

export interface FcmPayload {
  notification: { title: string; body: string };
  data: { kind: PushPayloadKind; appointmentId: string };
  android: { priority: 'high'; notification: { channelId: string; sound: string } };
  apns: { payload: { aps: { sound: string } } };
}
```

- [ ] **Step 2: Verify it compiles**

Run: `cd functions && npx tsc --noEmit`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add functions/src/types.ts
git commit -m "feat(functions): add push notification types"
```

---

## Task 2: Push templates module

**Files:**
- Create: `functions/src/services/pushTemplates.ts`
- Create: `functions/src/__tests__/pushTemplates.test.ts`

- [ ] **Step 1: Write failing tests**

Create `functions/src/__tests__/pushTemplates.test.ts`:

```ts
import { Timestamp } from 'firebase-admin/firestore';
import {
  buildReminderPayload,
  buildDailySummaryPayload,
  pluralizeRu,
} from '../services/pushTemplates';

const at = (h: number, m: number) =>
  Timestamp.fromDate(new Date(Date.UTC(2026, 4, 3, h, m)));

describe('pluralizeRu', () => {
  it.each([
    [1, 'запись'],
    [2, 'записи'],
    [3, 'записи'],
    [4, 'записи'],
    [5, 'записей'],
    [11, 'записей'],
    [21, 'запись'],
    [25, 'записей'],
  ])('returns correct form for %i', (n, expected) => {
    expect(pluralizeRu(n, ['запись', 'записи', 'записей'])).toBe(expected);
  });
});

describe('buildReminderPayload', () => {
  const apt = { clientName: 'Ali', clientPhone: '+998901234567', dateTime: at(10, 0) };

  it('builds Uzbek 1h reminder', () => {
    const p = buildReminderPayload('reminder_1h', 'uz', apt, 'apt-1');
    expect(p.notification.title).toBe('Yaqin yozuv');
    expect(p.notification.body).toContain('Ali');
    expect(p.notification.body).toContain('+998901234567');
    expect(p.data.kind).toBe('reminder_1h');
    expect(p.data.appointmentId).toBe('apt-1');
    expect(p.android.notification.channelId).toBe('reminders');
  });

  it('builds Russian 15m reminder', () => {
    const p = buildReminderPayload('reminder_15m', 'ru', apt, 'apt-1');
    expect(p.notification.title).toBe('Осталось 15 минут');
    expect(p.notification.body).toContain('Ali');
  });
});

describe('buildDailySummaryPayload', () => {
  it('returns free-day template when N=0 (uz)', () => {
    const p = buildDailySummaryPayload('uz', []);
    expect(p.notification.title).toBe("Bugun bo'sh kun");
    expect(p.data.kind).toBe('daily_summary');
    expect(p.data.appointmentId).toBe('');
  });

  it('returns free-day template when N=0 (ru)', () => {
    const p = buildDailySummaryPayload('ru', []);
    expect(p.notification.title).toBe('Сегодня свободный день');
  });

  it('returns count + first appointment (uz)', () => {
    const list = [
      { clientName: 'Ali', clientPhone: '+998', dateTime: at(9, 30) },
      { clientName: 'Vali', clientPhone: '+998', dateTime: at(11, 0) },
    ];
    const p = buildDailySummaryPayload('uz', list);
    expect(p.notification.title).toBe('Bugun 2 ta yozuv');
    expect(p.notification.body).toContain('Ali');
  });

  it('uses Russian pluralization', () => {
    const list = [
      { clientName: 'Анна', clientPhone: '+998', dateTime: at(9, 0) },
    ];
    const p = buildDailySummaryPayload('ru', list);
    expect(p.notification.title).toBe('Сегодня 1 запись');
  });

  it('uses записи for 2-4 (ru)', () => {
    const list = Array.from({ length: 3 }, (_, i) => ({
      clientName: `c${i}`,
      clientPhone: '+998',
      dateTime: at(9 + i, 0),
    }));
    const p = buildDailySummaryPayload('ru', list);
    expect(p.notification.title).toBe('Сегодня 3 записи');
  });
});
```

- [ ] **Step 2: Run tests, verify they fail**

Run: `cd functions && npx jest pushTemplates -t '' --no-coverage`
Expected: FAIL — "Cannot find module '../services/pushTemplates'"

- [ ] **Step 3: Implement `pushTemplates.ts`**

Create `functions/src/services/pushTemplates.ts`:

```ts
import { AppointmentData, FcmPayload, Language, PushKind } from '../types';

const CHANNEL_ID = 'reminders';

export function pluralizeRu(n: number, [one, few, many]: [string, string, string]): string {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod100 >= 11 && mod100 <= 14) return many;
  if (mod10 === 1) return one;
  if (mod10 >= 2 && mod10 <= 4) return few;
  return many;
}

function basePayload(title: string, body: string, kind: 'reminder_1h' | 'reminder_15m' | 'daily_summary', appointmentId: string): FcmPayload {
  return {
    notification: { title, body },
    data: { kind, appointmentId },
    android: { priority: 'high', notification: { channelId: CHANNEL_ID, sound: 'default' } },
    apns: { payload: { aps: { sound: 'default' } } },
  };
}

export function buildReminderPayload(
  kind: PushKind,
  language: Language,
  apt: AppointmentData,
  appointmentId: string
): FcmPayload {
  let title: string;
  let body: string;

  if (kind === 'reminder_1h') {
    if (language === 'uz') {
      title = 'Yaqin yozuv';
      body = `1 soatdan keyin: ${apt.clientName} (${apt.clientPhone})`;
    } else {
      title = 'Скоро запись';
      body = `Через 1 час: ${apt.clientName} (${apt.clientPhone})`;
    }
  } else {
    if (language === 'uz') {
      title = '15 daqiqa qoldi';
      body = `${apt.clientName} bilan uchrashuvga 15 daqiqa qoldi`;
    } else {
      title = 'Осталось 15 минут';
      body = `До встречи с ${apt.clientName} осталось 15 минут`;
    }
  }

  return basePayload(title, body, kind, appointmentId);
}

function formatHM(date: Date, timezone: string): string {
  // Format as HH:MM in target timezone using Intl.
  const fmt = new Intl.DateTimeFormat('en-GB', {
    hour: '2-digit', minute: '2-digit', hour12: false, timeZone: timezone,
  });
  return fmt.format(date);
}

export function buildDailySummaryPayload(
  language: Language,
  appointmentsToday: AppointmentData[],
  timezone: string = 'Asia/Tashkent'
): FcmPayload {
  const n = appointmentsToday.length;

  if (n === 0) {
    const [title, body] = language === 'uz'
      ? ["Bugun bo'sh kun", 'Yozuvingiz yo\'q — yaxshi dam oling 🌿']
      : ['Сегодня свободный день', 'Записей нет — хорошего отдыха 🌿'];
    return basePayload(title, body, 'daily_summary', '');
  }

  const sorted = [...appointmentsToday].sort(
    (a, b) => a.dateTime.toMillis() - b.dateTime.toMillis()
  );
  const first = sorted[0];
  const firstHM = formatHM(first.dateTime.toDate(), timezone);

  let title: string;
  let body: string;

  if (language === 'uz') {
    title = `Bugun ${n} ta yozuv`;
    body = `Birinchi yozuv: ${firstHM} — ${first.clientName}`;
  } else {
    const word = pluralizeRu(n, ['запись', 'записи', 'записей']);
    title = `Сегодня ${n} ${word}`;
    body = `Первая: ${firstHM} — ${first.clientName}`;
  }

  return basePayload(title, body, 'daily_summary', '');
}
```

- [ ] **Step 4: Run tests, verify they pass**

Run: `cd functions && npx jest pushTemplates --no-coverage`
Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add functions/src/services/pushTemplates.ts functions/src/__tests__/pushTemplates.test.ts
git commit -m "feat(functions): push templates and Russian pluralizer"
```

---

## Task 3: FCM service

**Files:**
- Create: `functions/src/services/fcmService.ts`
- Create: `functions/src/__tests__/fcmService.test.ts`

- [ ] **Step 1: Write failing tests for token aggregation logic**

Note: We test the pure helper `extractInvalidTokenIds` rather than the full `sendPushToMaster` (which calls `admin.messaging()`). Mocking the SDK is brittle; the integration is verified manually during smoke tests.

Create `functions/src/__tests__/fcmService.test.ts`:

```ts
import { extractInvalidTokenIds } from '../services/fcmService';

describe('extractInvalidTokenIds', () => {
  it('returns ids of responses with not-registered errors', () => {
    const responses = [
      { success: true } as any,
      { success: false, error: { code: 'messaging/registration-token-not-registered' } } as any,
      { success: false, error: { code: 'messaging/invalid-argument' } } as any,
    ];
    const tokenIds = ['t1', 't2', 't3'];
    expect(extractInvalidTokenIds(responses, tokenIds)).toEqual(['t2']);
  });

  it('returns empty array when all succeed', () => {
    const responses = [{ success: true } as any, { success: true } as any];
    expect(extractInvalidTokenIds(responses, ['a', 'b'])).toEqual([]);
  });
});
```

- [ ] **Step 2: Run tests, verify failure**

Run: `cd functions && npx jest fcmService --no-coverage`
Expected: FAIL — "Cannot find module '../services/fcmService'"

- [ ] **Step 3: Implement `fcmService.ts`**

Create `functions/src/services/fcmService.ts`:

```ts
import * as admin from 'firebase-admin';
import { FcmPayload } from '../types';

export interface SendResult {
  successCount: number;
  failureCount: number;
  invalidatedTokens: string[];
}

export function extractInvalidTokenIds(
  responses: admin.messaging.SendResponse[],
  tokenIds: string[]
): string[] {
  const invalid: string[] = [];
  responses.forEach((r, i) => {
    if (!r.success && r.error?.code === 'messaging/registration-token-not-registered') {
      invalid.push(tokenIds[i]);
    }
  });
  return invalid;
}

export async function sendPushToMaster(
  masterUID: string,
  payload: FcmPayload
): Promise<SendResult> {
  const tokensSnap = await admin
    .firestore()
    .collection('masters')
    .doc(masterUID)
    .collection('fcmTokens')
    .get();

  if (tokensSnap.empty) {
    return { successCount: 0, failureCount: 0, invalidatedTokens: [] };
  }

  const tokenIds: string[] = [];
  const tokens: string[] = [];
  tokensSnap.docs.forEach((d) => {
    tokenIds.push(d.id);
    tokens.push(d.data().token as string);
  });

  const message: admin.messaging.MulticastMessage = {
    tokens,
    notification: payload.notification,
    data: payload.data as Record<string, string>,
    android: payload.android as admin.messaging.AndroidConfig,
    apns: payload.apns as admin.messaging.ApnsConfig,
  };

  const result = await admin.messaging().sendEachForMulticast(message);
  const invalidIds = extractInvalidTokenIds(result.responses, tokenIds);

  if (invalidIds.length > 0) {
    const batch = admin.firestore().batch();
    invalidIds.forEach((id) =>
      batch.delete(
        admin.firestore().collection('masters').doc(masterUID).collection('fcmTokens').doc(id)
      )
    );
    await batch.commit();
  }

  return {
    successCount: result.successCount,
    failureCount: result.failureCount,
    invalidatedTokens: invalidIds,
  };
}
```

- [ ] **Step 4: Run tests + typecheck**

Run: `cd functions && npx jest fcmService --no-coverage && npx tsc --noEmit`
Expected: tests pass, no type errors.

- [ ] **Step 5: Commit**

```bash
git add functions/src/services/fcmService.ts functions/src/__tests__/fcmService.test.ts
git commit -m "feat(functions): FCM multicast service with invalid-token pruning"
```

---

## Task 4: Modify `onAppointmentCreated` to enqueue push reminders

**Files:**
- Modify: `functions/src/triggers/onAppointmentCreated.ts`
- Modify: `functions/src/__tests__/onAppointmentCreated.test.ts`

- [ ] **Step 1: Add failing tests for `buildPushQueueDocs`**

Append to `functions/src/__tests__/onAppointmentCreated.test.ts`:

```ts
import { buildPushQueueDocs } from '../triggers/onAppointmentCreated';
import { DEFAULT_PUSH_SETTINGS } from '../types';

describe('buildPushQueueDocs', () => {
  const masterUID = 'm1';
  const appointmentId = 'a1';
  const apt = (offsetMs: number) => ({
    clientName: 'Ali',
    clientPhone: '+998',
    dateTime: Timestamp.fromDate(new Date(Date.now() + offsetMs)),
  });

  it('returns 1h and 15m docs when both toggles on and times are future', () => {
    const docs = buildPushQueueDocs(masterUID, appointmentId, apt(3 * 3600 * 1000), 'uz', DEFAULT_PUSH_SETTINGS);
    expect(docs).toHaveLength(2);
    expect(docs.map((d) => d.kind).sort()).toEqual(['reminder_15m', 'reminder_1h']);
    expect(docs.every((d) => d.status === 'pending')).toBe(true);
    expect(docs.every((d) => d.masterUID === masterUID)).toBe(true);
  });

  it('skips reminder_1h when 1h-window has already passed', () => {
    const docs = buildPushQueueDocs(masterUID, appointmentId, apt(30 * 60 * 1000), 'uz', DEFAULT_PUSH_SETTINGS);
    expect(docs.map((d) => d.kind)).toEqual(['reminder_15m']);
  });

  it('skips both when appointment is in the past', () => {
    const docs = buildPushQueueDocs(masterUID, appointmentId, apt(-60_000), 'uz', DEFAULT_PUSH_SETTINGS);
    expect(docs).toHaveLength(0);
  });

  it('respects reminderOneHour toggle off', () => {
    const settings = { ...DEFAULT_PUSH_SETTINGS, reminderOneHour: false };
    const docs = buildPushQueueDocs(masterUID, appointmentId, apt(3 * 3600 * 1000), 'uz', settings);
    expect(docs.map((d) => d.kind)).toEqual(['reminder_15m']);
  });

  it('respects reminderFifteenMin toggle off', () => {
    const settings = { ...DEFAULT_PUSH_SETTINGS, reminderFifteenMin: false };
    const docs = buildPushQueueDocs(masterUID, appointmentId, apt(3 * 3600 * 1000), 'uz', settings);
    expect(docs.map((d) => d.kind)).toEqual(['reminder_1h']);
  });

  it('returns docId-friendly suffix in returned tuple', () => {
    const docs = buildPushQueueDocs(masterUID, appointmentId, apt(3 * 3600 * 1000), 'uz', DEFAULT_PUSH_SETTINGS);
    const ids = docs.map((d) => d.docId);
    expect(ids).toContain('a1_1h');
    expect(ids).toContain('a1_15m');
  });
});
```

- [ ] **Step 2: Run tests, verify failure**

Run: `cd functions && npx jest onAppointmentCreated --no-coverage`
Expected: FAIL — `buildPushQueueDocs` is not exported.

- [ ] **Step 3: Modify trigger to add `buildPushQueueDocs` and queue writes**

Replace `functions/src/triggers/onAppointmentCreated.ts` with:

```ts
import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import {
  AppointmentData,
  DEFAULT_PUSH_SETTINGS,
  Language,
  NotificationQueueDoc,
  PushKind,
  PushQueueDoc,
  PushSettings,
} from '../types';

const ONE_HOUR_MS = 60 * 60 * 1000;
const FIFTEEN_MIN_MS = 15 * 60 * 1000;

export function buildNotification(
  masterUID: string,
  appointmentId: string,
  data: AppointmentData,
  rawLanguage: string
): NotificationQueueDoc | null {
  const apptDate = data.dateTime.toDate();
  const sendAtDate = new Date(apptDate.getTime() - ONE_HOUR_MS);

  if (sendAtDate <= new Date()) return null;

  const language: Language = rawLanguage.toLowerCase() === 'uz' ? 'uz' : 'ru';

  return {
    appointmentId,
    masterUID,
    clientName: data.clientName,
    clientPhone: data.clientPhone,
    sendAt: Timestamp.fromDate(sendAtDate),
    language,
    status: 'pending',
    error: null,
  };
}

export interface PushQueueBuildResult extends PushQueueDoc {
  docId: string;
}

export function buildPushQueueDocs(
  masterUID: string,
  appointmentId: string,
  data: AppointmentData,
  rawLanguage: string,
  settings: PushSettings
): PushQueueBuildResult[] {
  const language: Language = rawLanguage.toLowerCase() === 'uz' ? 'uz' : 'ru';
  const apptMs = data.dateTime.toMillis();
  const now = Date.now();
  const out: PushQueueBuildResult[] = [];

  const cases: Array<{ kind: PushKind; offset: number; suffix: string; toggle: boolean }> = [
    { kind: 'reminder_1h', offset: ONE_HOUR_MS, suffix: '_1h', toggle: settings.reminderOneHour },
    { kind: 'reminder_15m', offset: FIFTEEN_MIN_MS, suffix: '_15m', toggle: settings.reminderFifteenMin },
  ];

  for (const c of cases) {
    if (!c.toggle) continue;
    const sendAtMs = apptMs - c.offset;
    if (sendAtMs <= now) continue;
    out.push({
      docId: `${appointmentId}${c.suffix}`,
      appointmentId,
      masterUID,
      kind: c.kind,
      sendAt: Timestamp.fromMillis(sendAtMs),
      status: 'pending',
      language,
      error: null,
    });
  }

  return out;
}

function extractPushSettings(masterDoc: FirebaseFirestore.DocumentData | undefined): PushSettings {
  const raw = masterDoc?.pushSettings;
  if (!raw) return DEFAULT_PUSH_SETTINGS;
  return {
    reminderOneHour: raw.reminderOneHour ?? DEFAULT_PUSH_SETTINGS.reminderOneHour,
    reminderFifteenMin: raw.reminderFifteenMin ?? DEFAULT_PUSH_SETTINGS.reminderFifteenMin,
    dailySummary: raw.dailySummary ?? DEFAULT_PUSH_SETTINGS.dailySummary,
    dailySummaryTime: raw.dailySummaryTime ?? DEFAULT_PUSH_SETTINGS.dailySummaryTime,
    timezone: raw.timezone ?? DEFAULT_PUSH_SETTINGS.timezone,
  };
}

export const onAppointmentCreated = onDocumentCreated(
  'masters/{masterUID}/appointments/{appointmentId}',
  async (event) => {
    const data = event.data?.data() as AppointmentData | undefined;
    if (!data) return;

    const { masterUID, appointmentId } = event.params;
    const db = admin.firestore();

    try {
      const masterSnap = await db.collection('masters').doc(masterUID).get();
      const masterData = masterSnap.data();
      const rawLanguage: string = masterData?.language ?? 'RU';
      const pushSettings = extractPushSettings(masterData);

      const sms = buildNotification(masterUID, appointmentId, data, rawLanguage);
      const pushDocs = buildPushQueueDocs(masterUID, appointmentId, data, rawLanguage, pushSettings);

      const writes: Promise<unknown>[] = [];
      if (sms) {
        writes.push(db.collection('notification_queue').doc(appointmentId).set(sms));
      }
      for (const pd of pushDocs) {
        const { docId, ...payload } = pd;
        writes.push(db.collection('push_queue').doc(docId).set(payload));
      }

      await Promise.all(writes);
    } catch (err) {
      console.error(`Failed to enqueue notifications for appointment ${appointmentId}:`, err);
    }
  }
);
```

- [ ] **Step 4: Run tests + typecheck**

Run: `cd functions && npx jest onAppointmentCreated --no-coverage && npx tsc --noEmit`
Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add functions/src/triggers/onAppointmentCreated.ts functions/src/__tests__/onAppointmentCreated.test.ts
git commit -m "feat(functions): enqueue push reminders alongside SMS on appointment create"
```

---

## Task 5: Modify `onAppointmentDeleted` to dequeue push docs

**Files:**
- Modify: `functions/src/triggers/onAppointmentDeleted.ts`

- [ ] **Step 1: Update trigger to also delete push queue docs**

Replace `functions/src/triggers/onAppointmentDeleted.ts` with:

```ts
import * as admin from 'firebase-admin';
import { onDocumentDeleted } from 'firebase-functions/v2/firestore';

export const onAppointmentDeleted = onDocumentDeleted(
  'masters/{masterUID}/appointments/{appointmentId}',
  async (event) => {
    const { appointmentId } = event.params;
    const db = admin.firestore();

    try {
      const smsSnap = await db
        .collection('notification_queue')
        .where('appointmentId', '==', appointmentId)
        .where('status', '==', 'pending')
        .get();

      const pushIds = [`${appointmentId}_1h`, `${appointmentId}_15m`];
      const pushSnap = await Promise.all(
        pushIds.map((id) => db.collection('push_queue').doc(id).get())
      );

      const BATCH_LIMIT = 500;
      const refs: FirebaseFirestore.DocumentReference[] = [
        ...smsSnap.docs.map((d) => d.ref),
        ...pushSnap.filter((s) => s.exists).map((s) => s.ref),
      ];

      for (let i = 0; i < refs.length; i += BATCH_LIMIT) {
        const batch = db.batch();
        refs.slice(i, i + BATCH_LIMIT).forEach((r) => batch.delete(r));
        await batch.commit();
      }
    } catch (err) {
      console.error(`Failed to clean up notifications for appointment ${appointmentId}:`, err);
    }
  }
);
```

- [ ] **Step 2: Typecheck**

Run: `cd functions && npx tsc --noEmit`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add functions/src/triggers/onAppointmentDeleted.ts
git commit -m "feat(functions): dequeue push reminders when appointment deleted"
```

---

## Task 6: Add `onAppointmentUpdated` trigger

**Files:**
- Create: `functions/src/triggers/onAppointmentUpdated.ts`
- Create: `functions/src/__tests__/onAppointmentUpdated.test.ts`

- [ ] **Step 1: Write failing test for the change-detection helper**

Create `functions/src/__tests__/onAppointmentUpdated.test.ts`:

```ts
import { Timestamp } from 'firebase-admin/firestore';
import { dateTimeChanged } from '../triggers/onAppointmentUpdated';

const t = (ms: number) => Timestamp.fromMillis(ms);

describe('dateTimeChanged', () => {
  const base = { clientName: 'Ali', clientPhone: '+998', dateTime: t(1000) };

  it('returns true when dateTime differs', () => {
    expect(dateTimeChanged(base, { ...base, dateTime: t(2000) })).toBe(true);
  });

  it('returns false when dateTime is identical', () => {
    expect(dateTimeChanged(base, { ...base, clientName: 'Vali' })).toBe(false);
  });

  it('returns false when before/after are missing', () => {
    expect(dateTimeChanged(undefined, base)).toBe(false);
    expect(dateTimeChanged(base, undefined)).toBe(false);
  });
});
```

- [ ] **Step 2: Run tests, verify failure**

Run: `cd functions && npx jest onAppointmentUpdated --no-coverage`
Expected: FAIL — module not found.

- [ ] **Step 3: Implement the trigger**

Create `functions/src/triggers/onAppointmentUpdated.ts`:

```ts
import * as admin from 'firebase-admin';
import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { AppointmentData, DEFAULT_PUSH_SETTINGS, PushSettings } from '../types';
import { buildNotification, buildPushQueueDocs } from './onAppointmentCreated';

export function dateTimeChanged(
  before: AppointmentData | undefined,
  after: AppointmentData | undefined
): boolean {
  if (!before || !after) return false;
  return before.dateTime.toMillis() !== after.dateTime.toMillis();
}

function extractPushSettings(masterDoc: FirebaseFirestore.DocumentData | undefined): PushSettings {
  const raw = masterDoc?.pushSettings;
  if (!raw) return DEFAULT_PUSH_SETTINGS;
  return {
    reminderOneHour: raw.reminderOneHour ?? DEFAULT_PUSH_SETTINGS.reminderOneHour,
    reminderFifteenMin: raw.reminderFifteenMin ?? DEFAULT_PUSH_SETTINGS.reminderFifteenMin,
    dailySummary: raw.dailySummary ?? DEFAULT_PUSH_SETTINGS.dailySummary,
    dailySummaryTime: raw.dailySummaryTime ?? DEFAULT_PUSH_SETTINGS.dailySummaryTime,
    timezone: raw.timezone ?? DEFAULT_PUSH_SETTINGS.timezone,
  };
}

export const onAppointmentUpdated = onDocumentUpdated(
  'masters/{masterUID}/appointments/{appointmentId}',
  async (event) => {
    const before = event.data?.before.data() as AppointmentData | undefined;
    const after = event.data?.after.data() as AppointmentData | undefined;
    if (!dateTimeChanged(before, after) || !after) return;

    const { masterUID, appointmentId } = event.params;
    const db = admin.firestore();

    try {
      const masterSnap = await db.collection('masters').doc(masterUID).get();
      const masterData = masterSnap.data();
      const rawLanguage: string = masterData?.language ?? 'RU';
      const pushSettings = extractPushSettings(masterData);

      // Delete old queue entries (idempotent)
      const oldRefs = [
        db.collection('notification_queue').doc(appointmentId),
        db.collection('push_queue').doc(`${appointmentId}_1h`),
        db.collection('push_queue').doc(`${appointmentId}_15m`),
      ];
      const delBatch = db.batch();
      oldRefs.forEach((r) => delBatch.delete(r));
      await delBatch.commit();

      // Re-enqueue based on new dateTime
      const sms = buildNotification(masterUID, appointmentId, after, rawLanguage);
      const pushDocs = buildPushQueueDocs(masterUID, appointmentId, after, rawLanguage, pushSettings);

      const writes: Promise<unknown>[] = [];
      if (sms) writes.push(db.collection('notification_queue').doc(appointmentId).set(sms));
      for (const pd of pushDocs) {
        const { docId, ...payload } = pd;
        writes.push(db.collection('push_queue').doc(docId).set(payload));
      }
      await Promise.all(writes);
    } catch (err) {
      console.error(`Failed to re-queue notifications for appointment ${appointmentId}:`, err);
    }
  }
);
```

- [ ] **Step 4: Run tests + typecheck**

Run: `cd functions && npx jest onAppointmentUpdated --no-coverage && npx tsc --noEmit`
Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add functions/src/triggers/onAppointmentUpdated.ts functions/src/__tests__/onAppointmentUpdated.test.ts
git commit -m "feat(functions): re-enqueue notifications when appointment dateTime changes"
```

---

## Task 7: `sendPushReminders` scheduled function

**Files:**
- Create: `functions/src/scheduled/sendPushReminders.ts`
- Create: `functions/src/__tests__/sendPushReminders.test.ts`

- [ ] **Step 1: Write failing tests for `shouldStillSend`**

Create `functions/src/__tests__/sendPushReminders.test.ts`:

```ts
import { shouldStillSend } from '../scheduled/sendPushReminders';
import { DEFAULT_PUSH_SETTINGS } from '../types';

describe('shouldStillSend', () => {
  it('returns true when reminder_1h and toggle on', () => {
    expect(shouldStillSend('reminder_1h', DEFAULT_PUSH_SETTINGS)).toBe(true);
  });
  it('returns false when reminder_1h and toggle off', () => {
    expect(shouldStillSend('reminder_1h', { ...DEFAULT_PUSH_SETTINGS, reminderOneHour: false })).toBe(false);
  });
  it('returns true when reminder_15m and toggle on', () => {
    expect(shouldStillSend('reminder_15m', DEFAULT_PUSH_SETTINGS)).toBe(true);
  });
  it('returns false when reminder_15m and toggle off', () => {
    expect(shouldStillSend('reminder_15m', { ...DEFAULT_PUSH_SETTINGS, reminderFifteenMin: false })).toBe(false);
  });
});
```

- [ ] **Step 2: Run tests, verify failure**

Run: `cd functions && npx jest sendPushReminders --no-coverage`
Expected: FAIL — module not found.

- [ ] **Step 3: Implement the scheduled function**

Create `functions/src/scheduled/sendPushReminders.ts`:

```ts
import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { sendPushToMaster } from '../services/fcmService';
import { buildReminderPayload } from '../services/pushTemplates';
import {
  AppointmentData,
  DEFAULT_PUSH_SETTINGS,
  PushKind,
  PushQueueDoc,
  PushSettings,
} from '../types';

export function shouldStillSend(kind: PushKind, settings: PushSettings): boolean {
  if (kind === 'reminder_1h') return settings.reminderOneHour;
  return settings.reminderFifteenMin;
}

function extractPushSettings(masterDoc: FirebaseFirestore.DocumentData | undefined): PushSettings {
  const raw = masterDoc?.pushSettings;
  if (!raw) return DEFAULT_PUSH_SETTINGS;
  return {
    reminderOneHour: raw.reminderOneHour ?? DEFAULT_PUSH_SETTINGS.reminderOneHour,
    reminderFifteenMin: raw.reminderFifteenMin ?? DEFAULT_PUSH_SETTINGS.reminderFifteenMin,
    dailySummary: raw.dailySummary ?? DEFAULT_PUSH_SETTINGS.dailySummary,
    dailySummaryTime: raw.dailySummaryTime ?? DEFAULT_PUSH_SETTINGS.dailySummaryTime,
    timezone: raw.timezone ?? DEFAULT_PUSH_SETTINGS.timezone,
  };
}

export const sendPushReminders = onSchedule(
  { schedule: '* * * * *', timeZone: 'Asia/Tashkent' },
  async () => {
    const now = Timestamp.now();
    const db = admin.firestore();

    const snap = await db
      .collection('push_queue')
      .where('status', '==', 'pending')
      .where('sendAt', '<=', now)
      .limit(100)
      .get();

    if (snap.empty) return;

    for (const doc of snap.docs) {
      const data = doc.data() as PushQueueDoc;
      try {
        const masterSnap = await db.collection('masters').doc(data.masterUID).get();
        const settings = extractPushSettings(masterSnap.data());

        if (!shouldStillSend(data.kind, settings)) {
          await doc.ref.update({ status: 'cancelled' });
          continue;
        }

        const aptSnap = await db
          .collection('masters')
          .doc(data.masterUID)
          .collection('appointments')
          .doc(data.appointmentId)
          .get();
        const apt = aptSnap.data() as AppointmentData | undefined;
        if (!apt) {
          await doc.ref.update({ status: 'cancelled', error: 'appointment missing' });
          continue;
        }

        const payload = buildReminderPayload(data.kind, data.language, apt, data.appointmentId);
        await sendPushToMaster(data.masterUID, payload);
        await doc.ref.update({ status: 'sent' });
      } catch (err: unknown) {
        const msg = err instanceof Error ? err.message : 'Unknown error';
        await doc.ref.update({ status: 'failed', error: msg });
      }
    }
  }
);
```

- [ ] **Step 4: Run tests + typecheck**

Run: `cd functions && npx jest sendPushReminders --no-coverage && npx tsc --noEmit`
Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add functions/src/scheduled/sendPushReminders.ts functions/src/__tests__/sendPushReminders.test.ts
git commit -m "feat(functions): scheduled push reminder sender"
```

---

## Task 8: `sendDailySummaries` scheduled function

**Files:**
- Create: `functions/src/scheduled/sendDailySummaries.ts`
- Create: `functions/src/__tests__/sendDailySummaries.test.ts`

- [ ] **Step 1: Write failing tests for time-match helper**

Create `functions/src/__tests__/sendDailySummaries.test.ts`:

```ts
import { isWithinSummaryWindow, todayKeyForTimezone } from '../scheduled/sendDailySummaries';

describe('isWithinSummaryWindow', () => {
  // Tashkent is UTC+5 with no DST.
  const tz = 'Asia/Tashkent';

  it('matches when current time is within ±7 minutes of target HH:MM', () => {
    // 08:00 local = 03:00 UTC
    const now = new Date(Date.UTC(2026, 4, 3, 3, 5)); // 08:05 local
    expect(isWithinSummaryWindow('08:00', tz, now)).toBe(true);
  });

  it('rejects when current time is more than 7 minutes from target', () => {
    const now = new Date(Date.UTC(2026, 4, 3, 3, 10)); // 08:10 local
    expect(isWithinSummaryWindow('08:00', tz, now)).toBe(false);
  });

  it('handles midnight wrap', () => {
    const now = new Date(Date.UTC(2026, 4, 2, 18, 58)); // 23:58 local on May 2
    expect(isWithinSummaryWindow('00:00', tz, now)).toBe(true);
  });
});

describe('todayKeyForTimezone', () => {
  it('returns YYYYMMDD in target timezone', () => {
    const now = new Date(Date.UTC(2026, 4, 3, 3, 0)); // 08:00 local Tashkent
    expect(todayKeyForTimezone('Asia/Tashkent', now)).toBe('20260503');
  });

  it('rolls over before UTC midnight when timezone is ahead', () => {
    const now = new Date(Date.UTC(2026, 4, 2, 19, 30)); // 00:30 May 3 local Tashkent
    expect(todayKeyForTimezone('Asia/Tashkent', now)).toBe('20260503');
  });
});
```

- [ ] **Step 2: Run tests, verify failure**

Run: `cd functions && npx jest sendDailySummaries --no-coverage`
Expected: FAIL — module not found.

- [ ] **Step 3: Implement the scheduled function**

Create `functions/src/scheduled/sendDailySummaries.ts`:

```ts
import * as admin from 'firebase-admin';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { sendPushToMaster } from '../services/fcmService';
import { buildDailySummaryPayload } from '../services/pushTemplates';
import { AppointmentData, DEFAULT_PUSH_SETTINGS, Language, PushSettings } from '../types';

const WINDOW_MINUTES = 7;

function localTimeParts(timezone: string, now: Date): { hh: number; mm: number; date: string } {
  // 'en-GB' gives 24h. We use parts to extract HH:MM and YYYY-MM-DD reliably.
  const fmt = new Intl.DateTimeFormat('en-GB', {
    hour: '2-digit', minute: '2-digit', hour12: false,
    year: 'numeric', month: '2-digit', day: '2-digit',
    timeZone: timezone,
  });
  const parts = fmt.formatToParts(now);
  const get = (t: string) => parts.find((p) => p.type === t)?.value ?? '';
  const hh = parseInt(get('hour'), 10);
  const mm = parseInt(get('minute'), 10);
  const date = `${get('year')}-${get('month')}-${get('day')}`;
  return { hh, mm, date };
}

export function isWithinSummaryWindow(hhmm: string, timezone: string, now: Date): boolean {
  const [targetH, targetM] = hhmm.split(':').map(Number);
  const { hh, mm } = localTimeParts(timezone, now);
  const nowMin = hh * 60 + mm;
  const targetMin = targetH * 60 + targetM;
  let diff = Math.abs(nowMin - targetMin);
  if (diff > 720) diff = 1440 - diff; // wrap
  return diff <= WINDOW_MINUTES;
}

export function todayKeyForTimezone(timezone: string, now: Date): string {
  const { date } = localTimeParts(timezone, now);
  return date.replace(/-/g, '');
}

function extractPushSettings(masterDoc: FirebaseFirestore.DocumentData | undefined): PushSettings {
  const raw = masterDoc?.pushSettings;
  if (!raw) return DEFAULT_PUSH_SETTINGS;
  return {
    reminderOneHour: raw.reminderOneHour ?? DEFAULT_PUSH_SETTINGS.reminderOneHour,
    reminderFifteenMin: raw.reminderFifteenMin ?? DEFAULT_PUSH_SETTINGS.reminderFifteenMin,
    dailySummary: raw.dailySummary ?? DEFAULT_PUSH_SETTINGS.dailySummary,
    dailySummaryTime: raw.dailySummaryTime ?? DEFAULT_PUSH_SETTINGS.dailySummaryTime,
    timezone: raw.timezone ?? DEFAULT_PUSH_SETTINGS.timezone,
  };
}

async function fetchTodaysAppointments(
  db: FirebaseFirestore.Firestore,
  masterUID: string,
  timezone: string,
  now: Date
): Promise<AppointmentData[]> {
  // Compute local-day boundaries: convert local 00:00 and 24:00 to UTC.
  const { date } = localTimeParts(timezone, now);
  const [y, m, d] = date.split('-').map(Number);
  // Build a Date that represents "y-m-d 00:00 local". We do this by formatting offset.
  // Simpler: compute offset minutes from timezone at this instant.
  const fmt = new Intl.DateTimeFormat('en-GB', {
    timeZone: timezone, timeZoneName: 'shortOffset',
  });
  const tzPart = fmt.formatToParts(now).find((p) => p.type === 'timeZoneName')?.value ?? 'GMT+5';
  const match = /GMT([+-])(\d{1,2})(?::(\d{2}))?/.exec(tzPart);
  const sign = match?.[1] === '-' ? -1 : 1;
  const oh = parseInt(match?.[2] ?? '5', 10);
  const om = parseInt(match?.[3] ?? '0', 10);
  const offsetMin = sign * (oh * 60 + om);

  const localMidnightUtcMs = Date.UTC(y, m - 1, d, 0, 0) - offsetMin * 60 * 1000;
  const startTs = admin.firestore.Timestamp.fromMillis(localMidnightUtcMs);
  const endTs = admin.firestore.Timestamp.fromMillis(localMidnightUtcMs + 24 * 3600 * 1000);

  const snap = await db
    .collection('masters')
    .doc(masterUID)
    .collection('appointments')
    .where('dateTime', '>=', startTs)
    .where('dateTime', '<', endTs)
    .get();

  return snap.docs.map((d) => d.data() as AppointmentData);
}

export const sendDailySummaries = onSchedule(
  { schedule: 'every 15 minutes', timeZone: 'Asia/Tashkent' },
  async () => {
    const db = admin.firestore();
    const now = new Date();

    const mastersSnap = await db.collection('masters').get();

    for (const masterDoc of mastersSnap.docs) {
      const settings = extractPushSettings(masterDoc.data());
      if (!settings.dailySummary) continue;
      if (!isWithinSummaryWindow(settings.dailySummaryTime, settings.timezone, now)) continue;

      const masterUID = masterDoc.id;
      const dayKey = todayKeyForTimezone(settings.timezone, now);
      const logRef = db.collection('daily_summary_log').doc(`${masterUID}_${dayKey}`);

      try {
        // Idempotency: only one writer per day
        const claimed = await db.runTransaction(async (tx) => {
          const exist = await tx.get(logRef);
          if (exist.exists) return false;
          tx.set(logRef, {
            masterUID,
            dayKey,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          return true;
        });
        if (!claimed) continue;

        const appts = await fetchTodaysAppointments(db, masterUID, settings.timezone, now);
        const language: Language = (masterDoc.data().language ?? 'ru')
          .toString()
          .toLowerCase() === 'uz' ? 'uz' : 'ru';

        const payload = buildDailySummaryPayload(language, appts, settings.timezone);
        await sendPushToMaster(masterUID, payload);
      } catch (err) {
        console.error(`Daily summary failed for master ${masterUID}:`, err);
      }
    }
  }
);
```

- [ ] **Step 4: Run tests + typecheck**

Run: `cd functions && npx jest sendDailySummaries --no-coverage && npx tsc --noEmit`
Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add functions/src/scheduled/sendDailySummaries.ts functions/src/__tests__/sendDailySummaries.test.ts
git commit -m "feat(functions): scheduled daily summary sender with idempotency"
```

---

## Task 9: Wire `index.ts` exports

**Files:**
- Modify: `functions/src/index.ts`

- [ ] **Step 1: Update exports**

Replace `functions/src/index.ts` with:

```ts
import * as admin from 'firebase-admin';

admin.initializeApp();

export { onAppointmentCreated } from './triggers/onAppointmentCreated';
export { onAppointmentDeleted } from './triggers/onAppointmentDeleted';
export { onAppointmentUpdated } from './triggers/onAppointmentUpdated';
export { sendSmsReminders } from './scheduled/sendSmsReminders';
export { sendPushReminders } from './scheduled/sendPushReminders';
export { sendDailySummaries } from './scheduled/sendDailySummaries';
```

- [ ] **Step 2: Build to verify**

Run: `cd functions && npm run build`
Expected: clean build, `lib/` populated.

- [ ] **Step 3: Run all tests**

Run: `cd functions && npm test`
Expected: all suites pass.

- [ ] **Step 4: Commit**

```bash
git add functions/src/index.ts
git commit -m "feat(functions): wire push notification triggers and schedulers"
```

---

## Task 10: Add Flutter packages

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add dependencies**

In `pubspec.yaml`, under `dependencies:` (alongside existing entries), add:

```yaml
  firebase_messaging: ^15.1.3
  flutter_local_notifications: ^17.2.3
  app_settings: ^5.1.1
  crypto: ^3.0.5
```

- [ ] **Step 2: Install**

Run: `flutter pub get`
Expected: success.

- [ ] **Step 3: Configure iOS push capabilities**

In `ios/Runner.xcworkspace`, add the **Push Notifications** capability and enable **Background Modes → Remote notifications**.

Verify `ios/Runner/Info.plist` has at least:

```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

- [ ] **Step 4: Configure Android notification channel resources**

Create `android/app/src/main/res/values/strings.xml` (if absent) and add:

```xml
<resources>
  <string name="default_notification_channel_id">reminders</string>
</resources>
```

In `android/app/src/main/AndroidManifest.xml` inside `<application>`:

```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="@string/default_notification_channel_id"/>
```

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock ios/Runner/Info.plist android/app/src/main/res/values/strings.xml android/app/src/main/AndroidManifest.xml
git commit -m "chore: add firebase_messaging and local notifications deps"
```

---

## Task 11: `PushSettings` model

**Files:**
- Create: `lib/data/models/push_settings.dart`
- Create: `test/data/models/push_settings_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/data/models/push_settings_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:usta_book/data/models/push_settings.dart';

void main() {
  group('PushSettings', () {
    test('default values', () {
      const s = PushSettings.defaults();
      expect(s.reminderOneHour, true);
      expect(s.reminderFifteenMin, true);
      expect(s.dailySummary, true);
      expect(s.dailySummaryTime, '08:00');
      expect(s.timezone, 'Asia/Tashkent');
    });

    test('toMap/fromMap round-trip', () {
      const s = PushSettings(
        reminderOneHour: false,
        reminderFifteenMin: true,
        dailySummary: true,
        dailySummaryTime: '09:30',
        timezone: 'Asia/Tashkent',
      );
      final round = PushSettings.fromMap(s.toMap());
      expect(round, equals(s));
    });

    test('fromMap fills defaults for missing keys', () {
      final s = PushSettings.fromMap({'reminderOneHour': false});
      expect(s.reminderOneHour, false);
      expect(s.reminderFifteenMin, true);
      expect(s.dailySummaryTime, '08:00');
    });

    test('copyWith overrides only specified fields', () {
      const s = PushSettings.defaults();
      final s2 = s.copyWith(dailySummary: false);
      expect(s2.dailySummary, false);
      expect(s2.reminderOneHour, true);
    });
  });
}
```

- [ ] **Step 2: Run tests, verify failure**

Run: `flutter test test/data/models/push_settings_test.dart`
Expected: FAIL — file not found.

- [ ] **Step 3: Implement model**

Create `lib/data/models/push_settings.dart`:

```dart
import 'package:flutter/foundation.dart';

@immutable
class PushSettings {
  final bool reminderOneHour;
  final bool reminderFifteenMin;
  final bool dailySummary;
  final String dailySummaryTime; // 'HH:MM'
  final String timezone;

  const PushSettings({
    required this.reminderOneHour,
    required this.reminderFifteenMin,
    required this.dailySummary,
    required this.dailySummaryTime,
    required this.timezone,
  });

  const PushSettings.defaults()
      : reminderOneHour = true,
        reminderFifteenMin = true,
        dailySummary = true,
        dailySummaryTime = '08:00',
        timezone = 'Asia/Tashkent';

  Map<String, dynamic> toMap() => {
        'reminderOneHour': reminderOneHour,
        'reminderFifteenMin': reminderFifteenMin,
        'dailySummary': dailySummary,
        'dailySummaryTime': dailySummaryTime,
        'timezone': timezone,
      };

  factory PushSettings.fromMap(Map<String, dynamic> map) {
    const d = PushSettings.defaults();
    return PushSettings(
      reminderOneHour: map['reminderOneHour'] as bool? ?? d.reminderOneHour,
      reminderFifteenMin: map['reminderFifteenMin'] as bool? ?? d.reminderFifteenMin,
      dailySummary: map['dailySummary'] as bool? ?? d.dailySummary,
      dailySummaryTime: map['dailySummaryTime'] as String? ?? d.dailySummaryTime,
      timezone: map['timezone'] as String? ?? d.timezone,
    );
  }

  PushSettings copyWith({
    bool? reminderOneHour,
    bool? reminderFifteenMin,
    bool? dailySummary,
    String? dailySummaryTime,
    String? timezone,
  }) =>
      PushSettings(
        reminderOneHour: reminderOneHour ?? this.reminderOneHour,
        reminderFifteenMin: reminderFifteenMin ?? this.reminderFifteenMin,
        dailySummary: dailySummary ?? this.dailySummary,
        dailySummaryTime: dailySummaryTime ?? this.dailySummaryTime,
        timezone: timezone ?? this.timezone,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PushSettings &&
          other.reminderOneHour == reminderOneHour &&
          other.reminderFifteenMin == reminderFifteenMin &&
          other.dailySummary == dailySummary &&
          other.dailySummaryTime == dailySummaryTime &&
          other.timezone == timezone);

  @override
  int get hashCode => Object.hash(
        reminderOneHour,
        reminderFifteenMin,
        dailySummary,
        dailySummaryTime,
        timezone,
      );
}
```

- [ ] **Step 4: Run tests, verify pass**

Run: `flutter test test/data/models/push_settings_test.dart`
Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/data/models/push_settings.dart test/data/models/push_settings_test.dart
git commit -m "feat: PushSettings model"
```

---

## Task 12: `PushSettingsRepository`

**Files:**
- Create: `lib/domain/repositories/push_settings/push_settings_repository.dart`
- Create: `lib/data/repositories/push_settings/push_settings_repository_impl.dart`

- [ ] **Step 1: Create domain interface**

Create `lib/domain/repositories/push_settings/push_settings_repository.dart`:

```dart
import 'package:usta_book/data/models/push_settings.dart';

abstract class IPushSettingsRepository {
  Stream<PushSettings> watch(String masterUID);
  Future<PushSettings> read(String masterUID);
  Future<void> write(String masterUID, PushSettings settings);
  Future<void> updateField(String masterUID, Map<String, dynamic> partial);
}
```

- [ ] **Step 2: Create Firestore-backed implementation**

Create `lib/data/repositories/push_settings/push_settings_repository_impl.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:usta_book/data/models/push_settings.dart';
import 'package:usta_book/domain/repositories/push_settings/push_settings_repository.dart';

@Singleton(as: IPushSettingsRepository)
class PushSettingsRepository extends IPushSettingsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _masterRef(String uid) =>
      _db.collection('masters').doc(uid);

  @override
  Stream<PushSettings> watch(String masterUID) =>
      _masterRef(masterUID).snapshots().map((snap) {
        final data = snap.data();
        final raw = data?['pushSettings'] as Map<String, dynamic>?;
        if (raw == null) return const PushSettings.defaults();
        return PushSettings.fromMap(raw);
      });

  @override
  Future<PushSettings> read(String masterUID) async {
    final snap = await _masterRef(masterUID).get();
    final raw = snap.data()?['pushSettings'] as Map<String, dynamic>?;
    if (raw == null) return const PushSettings.defaults();
    return PushSettings.fromMap(raw);
  }

  @override
  Future<void> write(String masterUID, PushSettings settings) =>
      _masterRef(masterUID).set({'pushSettings': settings.toMap()}, SetOptions(merge: true));

  @override
  Future<void> updateField(String masterUID, Map<String, dynamic> partial) {
    final prefixed = partial.map((k, v) => MapEntry('pushSettings.$k', v));
    return _masterRef(masterUID).update(prefixed);
  }
}
```

- [ ] **Step 3: Regenerate DI**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `lib/core/di/di.config.dart` regenerated to include `IPushSettingsRepository`.

- [ ] **Step 4: Verify build**

Run: `flutter analyze lib/data/repositories/push_settings lib/domain/repositories/push_settings`
Expected: no issues.

- [ ] **Step 5: Commit**

```bash
git add lib/domain/repositories/push_settings lib/data/repositories/push_settings lib/core/di/di.config.dart
git commit -m "feat: PushSettingsRepository (interface + Firestore impl)"
```

---

## Task 13: `PushSettingsCubit`

**Files:**
- Create: `lib/bloc/push_settings/push_settings_state.dart`
- Create: `lib/bloc/push_settings/push_settings_cubit.dart`
- Create: `test/bloc/push_settings_cubit_test.dart`

- [ ] **Step 1: Create state**

Create `lib/bloc/push_settings/push_settings_state.dart`:

```dart
import 'package:equatable/equatable.dart' show EquatableMixin;
import 'package:usta_book/data/models/push_settings.dart';

class PushSettingsState with EquatableMixin {
  final PushSettings settings;
  final bool permissionGranted;

  const PushSettingsState({required this.settings, required this.permissionGranted});

  PushSettingsState copyWith({PushSettings? settings, bool? permissionGranted}) =>
      PushSettingsState(
        settings: settings ?? this.settings,
        permissionGranted: permissionGranted ?? this.permissionGranted,
      );

  @override
  List<Object?> get props => [settings, permissionGranted];
}
```

> If `equatable` isn't already a dependency, add it to `pubspec.yaml` (`equatable: ^2.0.5`) and run `flutter pub get`. Otherwise skip the import and override `==`/`hashCode` manually.

- [ ] **Step 2: Write failing cubit test**

Create `test/bloc/push_settings_cubit_test.dart`:

```dart
import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usta_book/bloc/push_settings/push_settings_cubit.dart';
import 'package:usta_book/data/models/push_settings.dart';
import 'package:usta_book/domain/repositories/push_settings/push_settings_repository.dart';

class _FakeRepo implements IPushSettingsRepository {
  final controller = StreamController<PushSettings>.broadcast();
  final List<Map<String, dynamic>> updates = [];
  PushSettings _current = const PushSettings.defaults();

  @override
  Stream<PushSettings> watch(String masterUID) => controller.stream;

  @override
  Future<PushSettings> read(String masterUID) async => _current;

  @override
  Future<void> write(String masterUID, PushSettings settings) async {
    _current = settings;
    controller.add(settings);
  }

  @override
  Future<void> updateField(String masterUID, Map<String, dynamic> partial) async {
    updates.add(partial);
  }
}

void main() {
  group('PushSettingsCubit', () {
    late _FakeRepo repo;
    setUp(() => repo = _FakeRepo());

    blocTest<PushSettingsCubit, PushSettingsState>(
      'emits new state when stream pushes',
      build: () => PushSettingsCubit(repo, 'm1'),
      act: (cubit) {
        cubit.start();
        repo.controller.add(const PushSettings.defaults().copyWith(dailySummary: false));
      },
      expect: () => [
        isA<PushSettingsState>().having((s) => s.settings.dailySummary, 'dailySummary', false),
      ],
    );

    test('toggle calls updateField with prefixed key', () async {
      final cubit = PushSettingsCubit(repo, 'm1');
      await cubit.setReminderOneHour(false);
      expect(repo.updates.last, {'reminderOneHour': false});
    });

    test('setDailySummaryTime stores HH:MM', () async {
      final cubit = PushSettingsCubit(repo, 'm1');
      await cubit.setDailySummaryTime(const TimeOfDay(hour: 9, minute: 5));
      expect(repo.updates.last, {'dailySummaryTime': '09:05'});
    });
  });
}
```

> Add `bloc_test: ^9.1.7` to `dev_dependencies` if absent.

- [ ] **Step 3: Run test, verify failure**

Run: `flutter test test/bloc/push_settings_cubit_test.dart`
Expected: FAIL — module not found.

- [ ] **Step 4: Implement cubit**

Create `lib/bloc/push_settings/push_settings_cubit.dart`:

```dart
import 'dart:async';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usta_book/bloc/push_settings/push_settings_state.dart';
import 'package:usta_book/data/models/push_settings.dart';
import 'package:usta_book/domain/repositories/push_settings/push_settings_repository.dart';

class PushSettingsCubit extends Cubit<PushSettingsState> {
  final IPushSettingsRepository _repo;
  final String _masterUID;
  StreamSubscription<PushSettings>? _sub;

  PushSettingsCubit(this._repo, this._masterUID)
      : super(const PushSettingsState(
          settings: PushSettings.defaults(),
          permissionGranted: false,
        ));

  void start() {
    _sub?.cancel();
    _sub = _repo.watch(_masterUID).listen((s) => emit(state.copyWith(settings: s)));
  }

  void setPermissionGranted(bool granted) =>
      emit(state.copyWith(permissionGranted: granted));

  Future<void> setReminderOneHour(bool v) async {
    emit(state.copyWith(settings: state.settings.copyWith(reminderOneHour: v)));
    await _repo.updateField(_masterUID, {'reminderOneHour': v});
  }

  Future<void> setReminderFifteenMin(bool v) async {
    emit(state.copyWith(settings: state.settings.copyWith(reminderFifteenMin: v)));
    await _repo.updateField(_masterUID, {'reminderFifteenMin': v});
  }

  Future<void> setDailySummary(bool v) async {
    emit(state.copyWith(settings: state.settings.copyWith(dailySummary: v)));
    await _repo.updateField(_masterUID, {'dailySummary': v});
  }

  Future<void> setDailySummaryTime(TimeOfDay t) async {
    final hhmm = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    emit(state.copyWith(settings: state.settings.copyWith(dailySummaryTime: hhmm)));
    await _repo.updateField(_masterUID, {'dailySummaryTime': hhmm});
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
```

- [ ] **Step 5: Run test, verify pass**

Run: `flutter test test/bloc/push_settings_cubit_test.dart`
Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/bloc/push_settings test/bloc/push_settings_cubit_test.dart pubspec.yaml pubspec.lock
git commit -m "feat: PushSettingsCubit with toggle and time picker actions"
```

---

## Task 14: `PushNotificationService`

**Files:**
- Create: `lib/data/sources/firebase/push_notification_service.dart`
- Create: `lib/firebase_messaging_background_handler.dart`

- [ ] **Step 1: Create top-level background handler**

Create `lib/firebase_messaging_background_handler.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:usta_book/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // System tray notification is rendered by FCM automatically; nothing to do here.
}
```

- [ ] **Step 2: Implement service**

Create `lib/data/sources/firebase/push_notification_service.dart`:

```dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class PushNotificationService {
  static const String _channelId = 'reminders';
  static const String _channelName = 'Reminders';

  final FirebaseMessaging _fm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  GoRouter? _router;

  void attachRouter(GoRouter router) {
    _router = router;
  }

  Future<void> initialize() async {
    // Local notifications setup
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (resp) {
        if (resp.payload != null) {
          _routeFromData(jsonDecode(resp.payload!) as Map<String, dynamic>);
        }
      },
    );

    // Android channel
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
    );
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Foreground handler — show heads-up via local notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      final n = msg.notification;
      if (n == null) return;
      _local.show(
        n.hashCode,
        n.title,
        n.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId, _channelName,
            importance: Importance.high, priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode(msg.data),
      );
    });

    // Tap-to-open (background)
    FirebaseMessaging.onMessageOpenedApp.listen((msg) => _routeFromData(msg.data));

    // Tap-to-open (terminated)
    final initial = await _fm.getInitialMessage();
    if (initial != null) _routeFromData(initial.data);
  }

  Future<bool> requestPermissionAndRegisterToken(String masterUID) async {
    final settings = await _fm.requestPermission(alert: true, badge: true, sound: true);
    final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!granted) return false;

    final token = await _fm.getToken();
    if (token != null) await _writeToken(masterUID, token);

    _fm.onTokenRefresh.listen((newToken) => _writeToken(masterUID, newToken));
    return true;
  }

  Future<void> deleteTokenForMaster(String masterUID) async {
    final token = await _fm.getToken();
    if (token != null) {
      final id = _tokenId(token);
      await FirebaseFirestore.instance
          .collection('masters').doc(masterUID).collection('fcmTokens').doc(id).delete();
    }
    await _fm.deleteToken();
  }

  Future<NotificationSettings> currentPermissionSettings() => _fm.getNotificationSettings();

  Future<void> _writeToken(String masterUID, String token) async {
    final id = _tokenId(token);
    final ref = FirebaseFirestore.instance
        .collection('masters').doc(masterUID).collection('fcmTokens').doc(id);

    final platform = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
    final exists = (await ref.get()).exists;
    if (exists) {
      await ref.update({'lastSeenAt': FieldValue.serverTimestamp(), 'token': token, 'platform': platform});
    } else {
      await ref.set({
        'token': token,
        'platform': platform,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeenAt': FieldValue.serverTimestamp(),
      });
    }
  }

  String _tokenId(String token) => sha256.convert(utf8.encode(token)).toString().substring(0, 16);

  void _routeFromData(Map<String, dynamic> data) {
    final router = _router;
    if (router == null) return;
    final kind = data['kind'] as String?;
    final apptId = data['appointmentId'] as String?;
    if (kind == 'reminder_1h' || kind == 'reminder_15m') {
      if (apptId != null && apptId.isNotEmpty) {
        router.go('/schedule');
      }
    } else if (kind == 'daily_summary') {
      router.go('/home');
    }
  }
}
```

> The two `router.go` paths above are placeholders that match the existing routes used by the app's bottom navigation. Adjust to the exact route names used in `lib/presentation/router/app_route.dart` if they differ; the routing-on-tap intent is "go to the schedule for that day" / "go to home".

- [ ] **Step 3: Regenerate DI**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: DI config registers `PushNotificationService`.

- [ ] **Step 4: Static analysis**

Run: `flutter analyze lib/data/sources/firebase/push_notification_service.dart lib/firebase_messaging_background_handler.dart`
Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add lib/data/sources/firebase/push_notification_service.dart lib/firebase_messaging_background_handler.dart lib/core/di/di.config.dart
git commit -m "feat: PushNotificationService for FCM init, permission, and token registration"
```

---

## Task 15: Wire `main.dart` initialization

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Update `main()` to initialize push and register background handler**

Edit `lib/main.dart`. After `await Firebase.initializeApp(...)` and before `await initDi();`, add:

```dart
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
```

After `await initDi();`, add:

```dart
  await inject<PushNotificationService>().initialize();
```

Imports to add at top of file:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:usta_book/data/sources/firebase/push_notification_service.dart';
import 'package:usta_book/firebase_messaging_background_handler.dart';
```

In `_MyAppState.initState`, after `_router = AppRoute.router(...)`, attach the router:

```dart
    inject<PushNotificationService>().attachRouter(_router);
```

In `MultiBlocProvider.providers`, register the new cubit (lazy creation, started after auth):

```dart
          BlocProvider<PushSettingsCubit>(
            create: (context) {
              final uid = FirebaseService.currentMasterUid ?? '';
              return PushSettingsCubit(inject(), uid)..start();
            },
          ),
```

Also add the import for `PushSettingsCubit`:

```dart
import 'package:usta_book/bloc/push_settings/push_settings_cubit.dart';
```

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/main.dart`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat: initialize push notifications and register background handler"
```

---

## Task 16: Permission request on first home entry

**Files:**
- Modify: `lib/data/sources/local/shared_pref.dart`
- Modify: `lib/presentation/home/home_page.dart` (or whichever file is the home screen — verify in `lib/presentation/home/`)

- [ ] **Step 1: Add `pushOnboarded` helpers to `ShredPrefService`**

In `lib/data/sources/local/shared_pref.dart`, add to `SharedPrefString`:

```dart
  static String pushOnboardedPrefix = 'push_onboarded_';
```

And add methods on `ShredPrefService`:

```dart
  Future<void> markPushOnboarded(String masterUID) =>
      _preferences.setBool('${SharedPrefString.pushOnboardedPrefix}$masterUID', true);

  bool getPushOnboarded(String masterUID) =>
      _preferences.getBool('${SharedPrefString.pushOnboardedPrefix}$masterUID') ?? false;
```

- [ ] **Step 2: Hook permission request in home screen `initState`**

Identify the home screen entry point. Inspect `lib/presentation/home/`:

```bash
ls lib/presentation/home/
```

The screen's `initState` should run, after the first frame:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) async {
  final uid = FirebaseService.currentMasterUid;
  if (uid == null) return;
  final prefs = inject<ShredPrefService>();
  if (prefs.getPushOnboarded(uid)) return;

  final granted = await inject<PushNotificationService>()
      .requestPermissionAndRegisterToken(uid);
  await prefs.markPushOnboarded(uid);

  // Persist default push settings on first grant
  if (granted) {
    await inject<IPushSettingsRepository>()
        .write(uid, const PushSettings.defaults());
  }
});
```

Add imports as needed:

```dart
import 'package:usta_book/core/di/inject.dart';
import 'package:usta_book/data/sources/firebase/firebase_service.dart';
import 'package:usta_book/data/sources/firebase/push_notification_service.dart';
import 'package:usta_book/data/sources/local/shared_pref.dart';
import 'package:usta_book/data/models/push_settings.dart';
import 'package:usta_book/domain/repositories/push_settings/push_settings_repository.dart';
```

- [ ] **Step 3: Static analysis**

Run: `flutter analyze lib/data/sources/local/shared_pref.dart lib/presentation/home`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/data/sources/local/shared_pref.dart lib/presentation/home
git commit -m "feat: request push permission on first home entry per master"
```

---

## Task 17: Token cleanup on logout

**Files:**
- Modify: `lib/bloc/auth/auth_cubit.dart`

- [ ] **Step 1: Locate the logout method**

Open `lib/bloc/auth/auth_cubit.dart`. Find the method that signs the user out (look for `signOut` / `logOut`).

- [ ] **Step 2: Delete FCM token before sign-out**

Before `FirebaseAuth.instance.signOut()` is called, add:

```dart
final uid = FirebaseAuth.instance.currentUser?.uid;
if (uid != null) {
  try {
    await inject<PushNotificationService>().deleteTokenForMaster(uid);
  } catch (e) {
    // best-effort
  }
}
```

Add imports:

```dart
import 'package:usta_book/core/di/inject.dart';
import 'package:usta_book/data/sources/firebase/push_notification_service.dart';
```

- [ ] **Step 3: Static analysis**

Run: `flutter analyze lib/bloc/auth/auth_cubit.dart`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/bloc/auth/auth_cubit.dart
git commit -m "feat: delete FCM token on logout"
```

---

## Task 18: Notification settings screen

**Files:**
- Create: `lib/presentation/profile/notification_settings_screen.dart`
- Modify: `lib/presentation/profile/profile_page.dart`
- Modify: `lib/presentation/router/app_route.dart`

- [ ] **Step 1: Create the screen**

Create `lib/presentation/profile/notification_settings_screen.dart`:

```dart
import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usta_book/bloc/push_settings/push_settings_cubit.dart';
import 'package:usta_book/bloc/push_settings/push_settings_state.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';

class NotificationSettingsScreen extends StatefulWidget {
  static const String tag = '/profile/notifications';
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _permissionGranted = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final s = await FirebaseMessaging.instance.getNotificationSettings();
    if (!mounted) return;
    setState(() {
      _permissionGranted = s.authorizationStatus == AuthorizationStatus.authorized ||
          s.authorizationStatus == AuthorizationStatus.provisional;
    });
  }

  Future<void> _pickTime(BuildContext context, String currentHHMM) async {
    final parts = currentHHMM.split(':').map(int.parse).toList();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: parts[0], minute: parts[1]),
    );
    if (picked != null && context.mounted) {
      await context.read<PushSettingsCubit>().setDailySummaryTime(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).profile;
    return Scaffold(
      appBar: AppBar(title: Text(tr.notifications)),
      body: BlocBuilder<PushSettingsCubit, PushSettingsState>(
        builder: (context, state) {
          final s = state.settings;
          final disabled = !_permissionGranted;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (disabled)
                Card(
                  color: Colors.amber.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr.notification_permission_off),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => AppSettings.openAppSettings(),
                          child: Text(tr.open_settings),
                        ),
                      ],
                    ),
                  ),
                ),
              SwitchListTile(
                title: Text(tr.reminder_one_hour),
                subtitle: Text(tr.reminder_one_hour_subtitle),
                value: s.reminderOneHour,
                onChanged: disabled
                    ? null
                    : (v) => context.read<PushSettingsCubit>().setReminderOneHour(v),
              ),
              SwitchListTile(
                title: Text(tr.reminder_fifteen_min),
                value: s.reminderFifteenMin,
                onChanged: disabled
                    ? null
                    : (v) => context.read<PushSettingsCubit>().setReminderFifteenMin(v),
              ),
              const Divider(),
              SwitchListTile(
                title: Text(tr.daily_summary),
                subtitle: Text(tr.daily_summary_subtitle),
                value: s.dailySummary,
                onChanged: disabled
                    ? null
                    : (v) => context.read<PushSettingsCubit>().setDailySummary(v),
              ),
              if (s.dailySummary)
                ListTile(
                  enabled: !disabled,
                  title: Text(tr.daily_summary_time),
                  trailing: Text(s.dailySummaryTime),
                  onTap: disabled ? null : () => _pickTime(context, s.dailySummaryTime),
                ),
            ],
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Add a route**

In `lib/presentation/router/app_route.dart`, register the route alongside existing ones:

```dart
GoRoute(
  path: NotificationSettingsScreen.tag,
  builder: (_, __) => const NotificationSettingsScreen(),
),
```

Add the import. (If the router uses `routes:` lists per shell, add it to the shell where Profile lives.)

- [ ] **Step 3: Wire the Profile entry**

In `lib/presentation/profile/profile_page.dart`, change the existing `tr.profile.notifications` `ProfileItem.onTap` (currently `() {}`):

```dart
onTap: () => context.push(NotificationSettingsScreen.tag),
```

Add the import for `NotificationSettingsScreen`.

- [ ] **Step 4: Static analysis**

Run: `flutter analyze lib/presentation/profile lib/presentation/router/app_route.dart`
Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/profile/notification_settings_screen.dart lib/presentation/profile/profile_page.dart lib/presentation/router/app_route.dart
git commit -m "feat: notification settings screen with toggles, time picker, permission banner"
```

---

## Task 19: Localization strings

**Files:**
- Modify: `lib/core/localization/i18n/strings.i18n.json` (or the corresponding `_uz`/`_ru` files used by `slang`)

- [ ] **Step 1: Locate the slang source files**

Run: `ls lib/core/localization/i18n/`
Find files like `strings.i18n.json` (default) and `strings_ru.i18n.json` (or `strings_uz.i18n.json`).

- [ ] **Step 2: Add new keys under `profile`**

In each language file, add (or merge with existing `profile` block):

```json
"profile": {
  "notifications": "Bildirishnomalar",
  "notification_permission_off": "Push bildirishnomalar OS sozlamalarida o'chirilgan",
  "open_settings": "Sozlamalarga o'tish",
  "reminder_one_hour": "Yozuvdan 1 soat oldin eslatma",
  "reminder_one_hour_subtitle": "Mijozga SMS bilan bir vaqtda push keladi",
  "reminder_fifteen_min": "Yozuvdan 15 daqiqa oldin eslatma",
  "daily_summary": "Kunlik xulosa",
  "daily_summary_subtitle": "Har kuni belgilangan vaqtda bugungi yozuvlar haqida xabar",
  "daily_summary_time": "Vaqt"
}
```

For Russian (`_ru` file):

```json
"profile": {
  "notifications": "Уведомления",
  "notification_permission_off": "Push-уведомления выключены в настройках системы",
  "open_settings": "Открыть настройки",
  "reminder_one_hour": "Напоминание за 1 час",
  "reminder_one_hour_subtitle": "Push приходит одновременно с SMS клиенту",
  "reminder_fifteen_min": "Напоминание за 15 минут",
  "daily_summary": "Ежедневная сводка",
  "daily_summary_subtitle": "Сообщение о записях текущего дня в выбранное время",
  "daily_summary_time": "Время"
}
```

- [ ] **Step 3: Regenerate slang strings**

Run: `dart run slang_build_runner` (or `dart run build_runner build --delete-conflicting-outputs` if integrated).
Expected: `lib/core/localization/i18n/strings.g.dart` regenerated.

- [ ] **Step 4: Verify analysis**

Run: `flutter analyze lib/presentation/profile/notification_settings_screen.dart`
Expected: no missing translation keys.

- [ ] **Step 5: Commit**

```bash
git add lib/core/localization/i18n
git commit -m "feat(i18n): notification settings strings (uz, ru)"
```

---

## Task 20: Firestore TTL for `daily_summary_log`

**Files:** none (cloud configuration)

- [ ] **Step 1: Create TTL policy via gcloud**

Run from a shell with `gcloud` authenticated to project `ustabook-c00e4`:

```bash
gcloud firestore fields ttls update createdAt \
  --collection-group=daily_summary_log \
  --enable-ttl \
  --project=ustabook-c00e4
```

Expected: TTL policy created. Documents with `createdAt` older than 30 days will be deleted by Firestore TTL.

> If `gcloud` access isn't available, configure manually at <https://console.cloud.google.com/firestore/databases/-default-/ttl?project=ustabook-c00e4>.

- [ ] **Step 2: (No commit — cloud config only)**

Document the change in the deployment notes or runbook if you have one.

---

## Task 21: Deploy and smoke test

**Files:** none (deployment)

- [ ] **Step 1: Build and deploy functions**

Run:

```bash
cd functions && npm run build && firebase deploy --only functions
```

Expected: all 6 functions deploy without error.

- [ ] **Step 2: Build and run the app on a real device**

iOS push requires a real device (simulator does not deliver pushes).

```bash
flutter run --release
```

- [ ] **Step 3: Smoke checklist**

- [ ] Login with a test account; on Home, accept the push permission prompt
- [ ] Open Profile → Notifications: all three toggles are on, time = 08:00, banner is hidden
- [ ] Create an appointment with `dateTime = now + 16 minutes`. Wait ~30 s — the 15-minute reminder push should arrive
- [ ] Toggle off "15 daqiqa oldin eslatma". Create another appointment 16 min in future. No 15-min push should fire
- [ ] In Profile → Notifications, tap the time row, set it to `now + 4 minutes`. Within ~7 minutes of that local time, daily summary push should arrive
- [ ] Logout, then login on a second device with the same account. Verify token cleanup did not delete the token registered on the second device

- [ ] **Step 4: Roll back if smoke fails**

If a critical issue surfaces, revert the deploy:

```bash
firebase functions:list
firebase functions:delete sendPushReminders sendDailySummaries onAppointmentUpdated
```

Re-deploy the previous-good build from `git`.

---

## Self-Review (run before declaring plan complete)

- [x] **Spec coverage** — every section in the spec maps to at least one task:
  - Architecture & types → Task 1
  - Push templates → Task 2
  - FCM service → Task 3
  - onAppointmentCreated → Task 4
  - onAppointmentDeleted → Task 5
  - onAppointmentUpdated → Task 6
  - sendPushReminders → Task 7
  - sendDailySummaries → Task 8
  - index.ts wiring → Task 9
  - Flutter packages + native config → Task 10
  - PushSettings model → Task 11
  - Repository → Task 12
  - Cubit → Task 13
  - Service → Task 14
  - main.dart wiring → Task 15
  - Permission flow → Task 16
  - Logout token cleanup → Task 17
  - Settings UI → Task 18
  - Localization → Task 19
  - TTL policy → Task 20
  - Deploy + smoke → Task 21

- [x] **Placeholder scan** — no "TBD"/"TODO" steps remain. Two flagged points: (a) routing-on-tap target in PushNotificationService is `/schedule` and `/home` to match the existing app's routes (instructions tell the implementer to verify against `app_route.dart` since the router file wasn't fully read here); (b) the Home screen entry path will be confirmed by `ls lib/presentation/home/` during Task 16 since the actual home screen file was not enumerated in advance.

- [x] **Type consistency** — `PushKind`, `PushPayloadKind`, `PushSettings`, `PushQueueDoc`, `FcmPayload`, `IPushSettingsRepository`, `PushSettingsCubit` all referenced consistently across tasks.
