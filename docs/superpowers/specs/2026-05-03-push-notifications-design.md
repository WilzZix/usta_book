# Push Notifications — Design

**Date:** 2026-05-03
**Status:** Approved (pending implementation)
**Owner:** nodirbek

## Goal

Add push notifications to the `usta_book` Flutter app for masters (the app users). Two notification kinds:

1. **Per-appointment reminders** — every appointment generates two pushes: 1 hour before and 15 minutes before.
2. **Daily summary** — once per day at a master-chosen time, summarising today's appointments (or a "free day" message if none).

Push targets the master only. Clients do not have the app; they continue receiving SMS reminders via the existing Eskiz pipeline.

## Decisions (from brainstorming)

| # | Decision |
|---|----------|
| 1 | Reminder kinds: per-appointment (1h + 15m) AND daily summary |
| 2 | Each reminder type has its own toggle in Profile → Notifications |
| 3 | Daily summary time is master-chosen (default `08:00`) |
| 4 | Empty days still send a "free day" summary |
| 5 | Push permission is requested after first login, on first Home screen entry |
| 6 | Implementation reuses the existing SMS queue pattern (Approach 1) |

## Architecture

### Components

```
Flutter app                         Firestore                           Cloud Functions
─────────                           ─────────                           ───────────────
firebase_messaging                  masters/{uid}                       triggers/
  ├─ permission                       ├─ language: 'uz'|'ru'              ├─ onAppointmentCreated  (modified)
  ├─ FCM token                        ├─ pushSettings: {…}                ├─ onAppointmentDeleted  (modified)
  └─ Settings repo write              │   ├─ reminderOneHour: bool        └─ onAppointmentUpdated  (new)
                                      │   ├─ reminderFifteenMin: bool
Settings screen                       │   ├─ dailySummary: bool           scheduled/
  ├─ 3 toggles                        │   ├─ dailySummaryTime: 'HH:MM'    ├─ sendSmsReminders      (unchanged)
  ├─ time picker (daily)              │   └─ timezone: 'Asia/Tashkent'    ├─ sendPushReminders     (new, every 1m)
  └─ permission banner                ├─ fcmTokens/{tokenId}              └─ sendDailySummaries    (new, every 15m)
                                      │   ├─ token: string
                                      │   ├─ platform: 'ios'|'android'    push_queue/{pushId}      (new collection)
                                      │   ├─ createdAt: Timestamp           ├─ masterUID
                                      │   └─ lastSeenAt: Timestamp          ├─ appointmentId
                                      └─ appointments/{aptId}              ├─ kind: 'reminder_1h'|'reminder_15m'
                                                                            ├─ sendAt: Timestamp
                                      daily_summary_log/{uid_YYYYMMDD}      ├─ status: 'pending'|'sent'|'failed'|'cancelled'
                                       └─ idempotency marker (TTL 30d)      ├─ language: 'uz'|'ru'
                                                                            └─ error: string|null
```

### Key choices

- **`push_queue` is a separate collection** from the existing `notification_queue` (SMS). Different audience (master vs client) and different cadence (1m vs 5m), but the same idempotent pattern (status + error fields, deterministic doc IDs).
- **FCM tokens live in a subcollection** `masters/{uid}/fcmTokens/{tokenHash}`, supporting multi-device. `tokenHash` is a stable derived ID so re-registration is idempotent.
- **Daily summary is NOT enqueued in `push_queue`** — the scheduled function matches masters by local time directly. Idempotency is enforced via `daily_summary_log/{masterUID}_{YYYYMMDD}` markers (created in a transaction).
- **Appointment update** requires a new trigger because changing `dateTime` invalidates queued reminders.

## Cloud Functions

### Files

```
functions/src/
├── index.ts                       (modified — new exports)
├── types.ts                       (modified — add PushQueueDoc, FcmToken, PushSettings)
├── services/
│   ├── eskizService.ts            (unchanged)
│   ├── fcmService.ts              (new)
│   └── pushTemplates.ts           (new)
├── triggers/
│   ├── onAppointmentCreated.ts    (modified)
│   ├── onAppointmentDeleted.ts    (modified)
│   └── onAppointmentUpdated.ts    (new)
└── scheduled/
    ├── sendSmsReminders.ts        (unchanged)
    ├── sendPushReminders.ts       (new)
    └── sendDailySummaries.ts      (new)
```

### `services/fcmService.ts`

Single responsibility: given a `masterUID` and a payload, fetch all `fcmTokens` for that master and send via `admin.messaging().sendEachForMulticast()`. On per-token errors:

- `messaging/registration-token-not-registered` → delete that token doc
- other errors → log, do not delete

Returns a result object: `{ successCount, failureCount, invalidatedTokens: string[] }`.

No payload-building logic in this file — payloads are built by `pushTemplates.ts` and passed in.

### `services/pushTemplates.ts`

Pure functions, no Firestore access:

```ts
buildReminderPayload(kind: 'reminder_1h'|'reminder_15m', language: 'uz'|'ru', a: AppointmentData): FcmPayload
buildDailySummaryPayload(language: 'uz'|'ru', appointmentsToday: AppointmentData[]): FcmPayload
pluralizeRu(n: number, forms: [string, string, string]): string
```

Templates table:

| Kind | Lang | Title | Body |
|------|------|-------|------|
| `reminder_1h` | uz | Yaqin yozuv | 1 soatdan keyin: **{clientName}** ({clientPhone}) |
| `reminder_1h` | ru | Скоро запись | Через 1 час: **{clientName}** ({clientPhone}) |
| `reminder_15m` | uz | 15 daqiqa qoldi | **{clientName}** bilan uchrashuvga 15 daqiqa qoldi |
| `reminder_15m` | ru | Осталось 15 минут | До встречи с **{clientName}** осталось 15 минут |
| `daily_summary` (N>0) | uz | Bugun {N} ta yozuv | Birinchi yozuv: {HH:MM} — {firstClientName} |
| `daily_summary` (N>0) | ru | Сегодня {N} {запись/записи/записей} | Первая: {HH:MM} — {firstClientName} |
| `daily_summary` (N=0) | uz | Bugun bo'sh kun | Yozuvingiz yo'q — yaxshi dam oling 🌿 |
| `daily_summary` (N=0) | ru | Сегодня свободный день | Записей нет — хорошего отдыха 🌿 |

FCM payload structure per push:

```ts
{
  notification: { title, body },
  data: { kind, appointmentId },        // appointmentId is '' for daily_summary
  android: { priority: 'high', notification: { channelId: 'reminders', sound: 'default' } },
  apns: { payload: { aps: { sound: 'default' } } },
}
```

### Triggers

**`onAppointmentCreated`** (modified) — keeps existing SMS queueing. Adds:

- Read `master.pushSettings` (defaults applied if absent: all toggles `true`, time `08:00`, timezone `Asia/Tashkent`)
- If `pushSettings.reminderOneHour` and `dateTime - 1h > now`: write `push_queue/{appointmentId}_1h` with kind `reminder_1h`
- If `pushSettings.reminderFifteenMin` and `dateTime - 15m > now`: write `push_queue/{appointmentId}_15m` with kind `reminder_15m`
- SMS and push enqueueing run in parallel; failure of one does not block the other

**`onAppointmentDeleted`** (modified) — alongside existing SMS dequeue, deletes `push_queue/{appointmentId}_1h` and `push_queue/{appointmentId}_15m` (delete is idempotent — missing docs are fine).

**`onAppointmentUpdated`** (new, `onDocumentUpdated` on the same path) — fires only when `dateTime` differs between before/after; otherwise returns immediately. When `dateTime` changes:

1. Delete the three queue docs (SMS `notification_queue/{appointmentId}` + the two push docs)
2. Re-run the same enqueue logic as `onAppointmentCreated`

Other field changes (e.g. `clientName`) do not trigger re-queueing.

### Scheduled functions

**`sendPushReminders`** (every 1 minute):

1. Query `push_queue` where `status == 'pending' AND sendAt <= now`, `limit(100)`
2. For each doc:
   - Re-read `master.pushSettings`. If the matching toggle is now `false`, mark `status: 'cancelled'` and skip
   - Build payload via `pushTemplates`
   - Call `fcmService.sendPushToMaster(masterUID, payload)`
   - On success: `status: 'sent'`. On failure: `status: 'failed', error: <message>`
3. Use a Firestore batch per group of 10 (mirrors existing SMS pattern for atomicity)

**`sendDailySummaries`** (every 15 minutes):

1. Query masters where `pushSettings.dailySummary == true` (paginated)
2. For each master, compute current local time using `pushSettings.timezone`. If `|localTime - dailySummaryTime| <= 7 minutes`, proceed
3. In a transaction, attempt to create `daily_summary_log/{masterUID}_{YYYYMMDD}`. If it already exists, abort (idempotent)
4. Query today's appointments for that master (date range: today 00:00 to 23:59 in master's timezone)
5. Build payload (use the empty-day template if N=0)
6. Send via `fcmService.sendPushToMaster()`
7. Log marker docs have a 30-day TTL via Firestore TTL policy

### `index.ts` exports

```ts
export { onAppointmentCreated } from './triggers/onAppointmentCreated';
export { onAppointmentDeleted } from './triggers/onAppointmentDeleted';
export { onAppointmentUpdated } from './triggers/onAppointmentUpdated';   // new
export { sendSmsReminders } from './scheduled/sendSmsReminders';
export { sendPushReminders } from './scheduled/sendPushReminders';        // new
export { sendDailySummaries } from './scheduled/sendDailySummaries';      // new
```

### Types added to `types.ts`

```ts
// Queue-only — daily summary is not enqueued
export type PushKind = 'reminder_1h' | 'reminder_15m';

// FCM payload data.kind — includes daily_summary
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
  dailySummaryTime: string;     // 'HH:MM'
  timezone: string;             // IANA, e.g. 'Asia/Tashkent'
}
```

## Flutter side

### Packages (pubspec.yaml)

```yaml
firebase_messaging: ^15.x       # compatible with firebase_core 4.1
flutter_local_notifications: ^17.x
```

No `permission_handler` — `firebase_messaging` handles push permission natively.

### New files

```
lib/
├── data/
│   ├── sources/firebase/
│   │   └── push_notification_service.dart
│   ├── repositories/push_settings/
│   │   └── push_settings_repository_impl.dart
│   └── models/
│       └── push_settings.dart
├── domain/repositories/push_settings/
│   └── push_settings_repository.dart
├── bloc/push_settings/
│   ├── push_settings_cubit.dart
│   └── push_settings_state.dart
└── presentation/profile/
    └── notification_settings_screen.dart       (or section in existing profile)
```

### `PushNotificationService` responsibilities

1. **`Future<void> initialize()`** — called from `main.dart` before `runApp`:
   - Register top-level `FirebaseMessaging.onBackgroundMessage` handler
   - Create Android notification channel (`reminders`)
   - Subscribe to `onMessage` (foreground) → display via `flutter_local_notifications`
   - Subscribe to `onMessageOpenedApp` and `getInitialMessage()` → route via `data.kind` and `data.appointmentId`

2. **`Future<bool> requestPermissionAndRegisterToken(String masterUID)`** — called from `HomeScreen.initState` once per master (gated by `SharedPreferences` flag `pushOnboarded:${masterUID}`):
   - `FirebaseMessaging.instance.requestPermission()` — explicit on iOS, Android 13+
   - On `authorized`/`provisional`: `getToken()`, write to `masters/{uid}/fcmTokens/{tokenHash}`
   - Subscribe to `onTokenRefresh` for re-registration
   - On denial: return `false`, the Settings screen will show the permission banner

3. **Token write** — doc ID is `sha256(token).slice(0, 16)`. Fields: `token`, `platform`, `createdAt` (only on first write), `lastSeenAt` (every write).

4. **Logout flow** — `AuthCubit.signOut()` calls `deleteToken()`, then deletes the Firestore doc.

5. **Foreground handling** — iOS does not show push by default while the app is foregrounded; on `onMessage` the service displays a heads-up via `flutter_local_notifications` using the `reminders` channel. Android also routes through the same channel for consistency.

6. **Navigation on tap** — `data.kind == reminder_*` routes to the appointment detail (or schedule for that day); `data.kind == daily_summary` routes to the home/schedule screen. Uses a global `GoRouter` reference accessible from the service (set up in `main.dart`).

7. **Background handler** — top-level `@pragma('vm:entry-point')` function that initializes Firebase but performs no extra work (the system tray notification is already rendered by FCM payload).

### `PushSettingsCubit`

- Reads `masters/{uid}/pushSettings` as a Firestore stream
- `toggle(field, value)` — optimistic UI update + debounced (500ms) Firestore `update()`; on error, snackbar + revert
- `setDailySummaryTime(TimeOfDay)` — writes `'HH:MM'` string

### Default `PushSettings` (created on first home entry after permission grant)

```dart
PushSettings(
  reminderOneHour: true,
  reminderFifteenMin: true,
  dailySummary: true,
  dailySummaryTime: '08:00',
  timezone: 'Asia/Tashkent',  // hard-coded default; in-app TZ picker is out of scope
)
```

`DateTime.now().timeZoneName` is unreliable as an IANA identifier across platforms, so we hard-code `'Asia/Tashkent'` for now. Adding a timezone picker (or auto-detection via `flutter_timezone`) is a future enhancement.

## Settings UI

Lives in the existing Profile section as a new "Bildirishnomalar / Уведомления" subsection (or its own screen — confirmed during implementation based on current Profile structure).

```
┌─ Bildirishnomalar ─────────────────────────────┐
│                                                 │
│ ⚠ OS push permission o'chirilgan                │  ← only when permission denied
│   [Sozlamalarga o'tish]                         │
│                                                 │
│ ─────────────────────────────────────────────   │
│                                                 │
│ Yozuvdan 1 soat oldin eslatma         [ ●━ ]   │
│ Mijozga SMS bilan bir vaqtda push keladi        │
│                                                 │
│ Yozuvdan 15 daqiqa oldin eslatma      [ ●━ ]   │
│                                                 │
│ ─────────────────────────────────────────────   │
│                                                 │
│ Kunlik xulosa                          [ ●━ ]   │
│ Har kuni belgilangan vaqtda bugungi              │
│ yozuvlar haqida xabar                           │
│                                                 │
│ Vaqt:                              08:00  ▸    │  ← visible when daily-summary toggle is on
│                                                 │
└─────────────────────────────────────────────────┘
```

### Behaviour

- **Permission banner** — shown when `getNotificationSettings().authorizationStatus == denied`. Tapping it calls `openAppSettings()` (via the `app_settings` package or `firebase_messaging` itself). Toggles are visually disabled while permission is denied; Firestore values are not mutated, so flipping permission back on restores state.
- **Toggles** — optimistic UI update; debounced Firestore write; revert on error.
- **Time picker** — Material `showTimePicker()`. Default `08:00`. Hidden when daily-summary toggle is off.
- **Localization** — all UI strings via the existing `slang` setup (uz/ru).
- **Cubit registration** — `PushSettingsCubit` joins the `MultiBlocProvider` in `main.dart`.

## Testing

### Cloud Functions (Jest)

```
functions/src/__tests__/
├── onAppointmentCreated.test.ts        (extended)
│   ├─ creates push_queue docs respecting toggles
│   └─ skips push_queue when reminder time has passed
├── onAppointmentDeleted.test.ts        (extended)
│   └─ deletes both _1h and _15m push_queue docs
├── onAppointmentUpdated.test.ts        (new)
│   ├─ re-enqueues only when dateTime changed
│   └─ does nothing for unrelated field changes
├── sendPushReminders.test.ts           (new)
│   ├─ skips items where toggle is now off (marks 'cancelled')
│   ├─ marks 'sent' on success
│   ├─ marks 'failed' with error on FCM error
│   └─ removes invalid tokens
├── sendDailySummaries.test.ts          (new)
│   ├─ matches masters by local time within ±7 min window
│   ├─ idempotent within same day (uses daily_summary_log)
│   └─ uses 'free day' template when N=0
└── pushTemplates.test.ts               (new)
    └─ snapshot per (kind × language × N)
```

### Flutter (`test/`)

- `push_notification_service_test.dart` — token write, refresh, logout-time deletion (with mocked `firebase_messaging`)
- `push_settings_cubit_test.dart` — toggle state, optimistic update, revert on error

### Manual smoke (pre-deploy)

1. Login on a test device, grant permission on Home
2. Create appointment with `dateTime = now + 16 minutes` → push should arrive ~30 s later
3. Toggle off `reminderFifteenMin` immediately → no push fires
4. Set `dailySummaryTime` to `now + 5 min`, wait → daily summary push arrives

## Error handling and observability

| Error | Where | Strategy |
|-------|-------|----------|
| FCM `registration-token-not-registered` | `sendPush*` | Delete token doc; mark push `failed` only if no other tokens succeeded |
| FCM `messaging/invalid-argument` | `sendPush*` | Mark `failed` + store error; `console.error` |
| FCM rate limit | `sendPush*` | Leave `pending`; next poll retries |
| Firestore read error | trigger / scheduled | `console.error`; let function fail so Cloud Functions retries |
| `master.pushSettings` missing (legacy account) | trigger | Apply defaults, log once |
| `master.pushSettings.timezone` missing | `sendDailySummaries` | Default `'Asia/Tashkent'`, log warning |

### Guards

- Each scheduled run is capped at `limit(100)` (existing SMS pattern); overflow rolls into the next poll
- `daily_summary_log` docs auto-expire via Firestore TTL after 30 days
- Flutter side routes errors to `FirebaseCrashlytics.recordError` (existing project convention)

## Out of scope

- Push notifications to clients (clients don't have the app — SMS continues to cover them)
- Rich-media notifications (images, action buttons)
- In-app notification inbox / history view
- Per-appointment push override (e.g. "no push for this one") — future enhancement if needed
- Topic-based pushes (e.g. promotional broadcasts to all masters)

## Migration notes

- Existing masters without `pushSettings`: triggers and scheduled functions apply defaults transparently. The Settings screen writes the explicit document on first interaction
- No backfill required for `push_queue` (only future appointments)
- Firestore TTL policy on `daily_summary_log` field `createdAt` — to be configured during deployment
