# SMS Reminder Cloud Functions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Firebase Cloud Functions that send an SMS via Eskiz.uz to the client 1 hour before their appointment, using a `notification_queue` collection to track and prevent duplicate messages.

**Architecture:** A Firestore trigger (`onAppointmentCreated`) writes a pending notification to `notification_queue` when a new appointment is created. A scheduled function (`sendSmsReminders`) runs every minute, picks up pending notifications whose `sendAt` time has passed, sends SMS via Eskiz.uz, and marks them sent. A second trigger (`onAppointmentDeleted`) removes pending notifications when an appointment is cancelled.

**Tech Stack:** Firebase Cloud Functions v2, TypeScript, firebase-admin SDK, axios, Jest + ts-jest

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `functions/package.json` | Create | Node deps, scripts |
| `functions/tsconfig.json` | Create | TypeScript config |
| `functions/.env` | Create | Eskiz credentials |
| `functions/src/types.ts` | Create | Shared TypeScript interfaces |
| `functions/src/services/eskizService.ts` | Create | Eskiz.uz login + send SMS |
| `functions/src/triggers/onAppointmentCreated.ts` | Create | Firestore CREATE trigger |
| `functions/src/triggers/onAppointmentDeleted.ts` | Create | Firestore DELETE trigger |
| `functions/src/scheduled/sendSmsReminders.ts` | Create | Scheduled every-minute function |
| `functions/src/index.ts` | Create | Exports all functions + initializes app |
| `functions/src/__tests__/eskizService.test.ts` | Create | Unit tests for Eskiz service |
| `functions/src/__tests__/onAppointmentCreated.test.ts` | Create | Unit tests for CREATE trigger logic |
| `functions/src/__tests__/sendSmsReminders.test.ts` | Create | Unit tests for scheduler logic |

---

## Task 1: Initialize functions/ project

**Files:**
- Create: `functions/package.json`
- Create: `functions/tsconfig.json`
- Create: `functions/.env`

- [ ] **Step 1: Create functions directory and package.json**

```bash
mkdir -p /Users/macbookpro/StudioProjects/usta_book/functions/src/__tests__
mkdir -p /Users/macbookpro/StudioProjects/usta_book/functions/src/services
mkdir -p /Users/macbookpro/StudioProjects/usta_book/functions/src/triggers
mkdir -p /Users/macbookpro/StudioProjects/usta_book/functions/src/scheduled
```

Create `functions/package.json`:
```json
{
  "name": "usta-book-functions",
  "version": "1.0.0",
  "engines": { "node": "18" },
  "main": "lib/index.js",
  "scripts": {
    "build": "tsc",
    "build:watch": "tsc --watch",
    "serve": "npm run build && firebase emulators:start --only functions",
    "deploy": "firebase deploy --only functions",
    "test": "jest"
  },
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^5.0.0",
    "axios": "^1.6.0"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/node": "^18.0.0",
    "jest": "^29.7.0",
    "ts-jest": "^29.1.0",
    "@types/jest": "^29.5.0"
  },
  "jest": {
    "preset": "ts-jest",
    "testEnvironment": "node",
    "testMatch": ["**/__tests__/**/*.test.ts"]
  }
}
```

- [ ] **Step 2: Create tsconfig.json**

Create `functions/tsconfig.json`:
```json
{
  "compilerOptions": {
    "module": "commonjs",
    "noImplicitReturns": true,
    "noUnusedLocals": true,
    "outDir": "lib",
    "sourceMap": true,
    "strict": true,
    "target": "es2017",
    "esModuleInterop": true
  },
  "compileOnSave": true,
  "include": ["src"],
  "exclude": ["node_modules", "lib", "src/__tests__"]
}
```

- [ ] **Step 3: Create .env file**

Create `functions/.env`:
```
ESKIZ_EMAIL=your@email.com
ESKIZ_PASSWORD=yourpassword
```

> Replace with real Eskiz.uz credentials from https://notify.eskiz.uz

- [ ] **Step 4: Install dependencies**

```bash
cd /Users/macbookpro/StudioProjects/usta_book/functions
npm install
```

Expected: `node_modules/` created, no errors.

- [ ] **Step 5: Commit**

```bash
cd /Users/macbookpro/StudioProjects/usta_book
git add functions/package.json functions/tsconfig.json
git commit -m "chore: initialize Firebase Cloud Functions project"
```

---

## Task 2: Define shared types

**Files:**
- Create: `functions/src/types.ts`

- [ ] **Step 1: Write types.ts**

Create `functions/src/types.ts`:
```typescript
import { Timestamp } from 'firebase-admin/firestore';

export type NotificationStatus = 'pending' | 'sent' | 'failed';
export type Language = 'uz' | 'ru';

export interface NotificationQueueDoc {
  appointmentId: string;
  masterUID: string;
  clientName: string;
  clientPhone: string;
  sendAt: Timestamp;
  language: Language;
  status: NotificationStatus;
  error: string | null;
}

export interface AppointmentData {
  clientName: string;
  clientPhone: string;
  dateTime: Timestamp;
}
```

- [ ] **Step 2: Commit**

```bash
cd /Users/macbookpro/StudioProjects/usta_book
git add functions/src/types.ts
git commit -m "feat: add shared types for notification queue"
```

---

## Task 3: Implement EskizService

**Files:**
- Create: `functions/src/services/eskizService.ts`
- Create: `functions/src/__tests__/eskizService.test.ts`

- [ ] **Step 1: Write failing tests**

Create `functions/src/__tests__/eskizService.test.ts`:
```typescript
import axios from 'axios';
import { getEskizToken, sendSms } from '../services/eskizService';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

describe('getEskizToken', () => {
  it('returns token from Eskiz response', async () => {
    mockedAxios.post.mockResolvedValueOnce({
      data: { data: { token: 'abc123' } },
    });

    const token = await getEskizToken('user@test.com', 'secret');

    expect(token).toBe('abc123');
    expect(mockedAxios.post).toHaveBeenCalledWith(
      'https://notify.eskiz.uz/api/auth/login',
      { email: 'user@test.com', password: 'secret' }
    );
  });

  it('throws if axios call fails', async () => {
    mockedAxios.post.mockRejectedValueOnce(new Error('Network error'));
    await expect(getEskizToken('u@t.com', 'p')).rejects.toThrow('Network error');
  });
});

describe('sendSms', () => {
  it('sends POST with correct payload and auth header', async () => {
    mockedAxios.post.mockResolvedValueOnce({ data: {} });

    await sendSms('my-token', '+998901234567', 'Hello');

    expect(mockedAxios.post).toHaveBeenCalledWith(
      'https://notify.eskiz.uz/api/message/sms/send',
      { mobile_phone: '+998901234567', message: 'Hello', from: '4546' },
      { headers: { Authorization: 'Bearer my-token' } }
    );
  });

  it('throws on API error', async () => {
    mockedAxios.post.mockRejectedValueOnce(new Error('401 Unauthorized'));
    await expect(sendSms('bad-token', '+998901234567', 'msg')).rejects.toThrow('401 Unauthorized');
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/macbookpro/StudioProjects/usta_book/functions
npx ts-jest config:show 2>/dev/null; npm test -- --testPathPattern=eskizService
```

Expected: FAIL — `Cannot find module '../services/eskizService'`

- [ ] **Step 3: Implement eskizService.ts**

Create `functions/src/services/eskizService.ts`:
```typescript
import axios from 'axios';

const BASE = 'https://notify.eskiz.uz/api';

export async function getEskizToken(email: string, password: string): Promise<string> {
  const res = await axios.post(`${BASE}/auth/login`, { email, password });
  return res.data.data.token as string;
}

export async function sendSms(token: string, phone: string, message: string): Promise<void> {
  await axios.post(
    `${BASE}/message/sms/send`,
    { mobile_phone: phone, message, from: '4546' },
    { headers: { Authorization: `Bearer ${token}` } }
  );
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
cd /Users/macbookpro/StudioProjects/usta_book/functions
npm test -- --testPathPattern=eskizService
```

Expected: PASS — 4 tests pass.

- [ ] **Step 5: Commit**

```bash
cd /Users/macbookpro/StudioProjects/usta_book
git add functions/src/services/eskizService.ts functions/src/__tests__/eskizService.test.ts
git commit -m "feat: implement EskizService (login + sendSms)"
```

---

## Task 4: Implement onAppointmentCreated trigger

**Files:**
- Create: `functions/src/triggers/onAppointmentCreated.ts`
- Create: `functions/src/__tests__/onAppointmentCreated.test.ts`

- [ ] **Step 1: Write failing tests**

Create `functions/src/__tests__/onAppointmentCreated.test.ts`:
```typescript
import { Timestamp } from 'firebase-admin/firestore';
import { buildNotification } from '../triggers/onAppointmentCreated';

describe('buildNotification', () => {
  const masterUID = 'master-1';
  const appointmentId = 'appt-1';
  const clientName = 'Ali';
  const clientPhone = '+998901234567';
  const language = 'uz';

  it('sets sendAt to 1 hour before appointment', () => {
    const apptTime = new Date('2026-05-01T10:00:00Z');
    const result = buildNotification(
      masterUID,
      appointmentId,
      { clientName, clientPhone, dateTime: Timestamp.fromDate(apptTime) },
      language
    );

    const expectedSendAt = new Date('2026-05-01T09:00:00Z');
    expect(result!.sendAt.toDate().getTime()).toBe(expectedSendAt.getTime());
  });

  it('returns null if appointment is less than 1 hour from now', () => {
    const soon = new Date(Date.now() + 30 * 60 * 1000); // 30 min from now
    const result = buildNotification(
      masterUID,
      appointmentId,
      { clientName, clientPhone, dateTime: Timestamp.fromDate(soon) },
      language
    );

    expect(result).toBeNull();
  });

  it('sets status to pending', () => {
    const apptTime = new Date(Date.now() + 3 * 60 * 60 * 1000); // 3h from now
    const result = buildNotification(
      masterUID,
      appointmentId,
      { clientName, clientPhone, dateTime: Timestamp.fromDate(apptTime) },
      language
    );

    expect(result!.status).toBe('pending');
    expect(result!.error).toBeNull();
  });

  it('maps language "RU" to "ru"', () => {
    const apptTime = new Date(Date.now() + 3 * 60 * 60 * 1000);
    const result = buildNotification(
      masterUID,
      appointmentId,
      { clientName, clientPhone, dateTime: Timestamp.fromDate(apptTime) },
      'RU'
    );

    expect(result!.language).toBe('ru');
  });

  it('maps language "UZ" to "uz"', () => {
    const apptTime = new Date(Date.now() + 3 * 60 * 60 * 1000);
    const result = buildNotification(
      masterUID,
      appointmentId,
      { clientName, clientPhone, dateTime: Timestamp.fromDate(apptTime) },
      'UZ'
    );

    expect(result!.language).toBe('uz');
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/macbookpro/StudioProjects/usta_book/functions
npm test -- --testPathPattern=onAppointmentCreated
```

Expected: FAIL — `Cannot find module '../triggers/onAppointmentCreated'`

- [ ] **Step 3: Implement onAppointmentCreated.ts**

Create `functions/src/triggers/onAppointmentCreated.ts`:
```typescript
import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { AppointmentData, Language, NotificationQueueDoc } from '../types';

const ONE_HOUR_MS = 60 * 60 * 1000;

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

export const onAppointmentCreated = onDocumentCreated(
  'masters/{masterUID}/appointments/{appointmentId}',
  async (event) => {
    const data = event.data?.data() as AppointmentData | undefined;
    if (!data) return;

    const { masterUID, appointmentId } = event.params;

    const masterDoc = await admin.firestore().collection('masters').doc(masterUID).get();
    const rawLanguage: string = masterDoc.data()?.language ?? 'RU';

    const notification = buildNotification(masterUID, appointmentId, data, rawLanguage);
    if (!notification) return;

    await admin.firestore().collection('notification_queue').add(notification);
  }
);
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
cd /Users/macbookpro/StudioProjects/usta_book/functions
npm test -- --testPathPattern=onAppointmentCreated
```

Expected: PASS — 5 tests pass.

- [ ] **Step 5: Commit**

```bash
cd /Users/macbookpro/StudioProjects/usta_book
git add functions/src/triggers/onAppointmentCreated.ts functions/src/__tests__/onAppointmentCreated.test.ts
git commit -m "feat: add onAppointmentCreated trigger with notification queue"
```

---

## Task 5: Implement onAppointmentDeleted trigger

**Files:**
- Create: `functions/src/triggers/onAppointmentDeleted.ts`

> This trigger has no pure logic to unit test separately (it only calls Firestore). Integration tested via emulator. We write the implementation directly.

- [ ] **Step 1: Create onAppointmentDeleted.ts**

Create `functions/src/triggers/onAppointmentDeleted.ts`:
```typescript
import * as admin from 'firebase-admin';
import { onDocumentDeleted } from 'firebase-functions/v2/firestore';

export const onAppointmentDeleted = onDocumentDeleted(
  'masters/{masterUID}/appointments/{appointmentId}',
  async (event) => {
    const { appointmentId } = event.params;

    const snapshot = await admin
      .firestore()
      .collection('notification_queue')
      .where('appointmentId', '==', appointmentId)
      .where('status', '==', 'pending')
      .get();

    if (snapshot.empty) return;

    const batch = admin.firestore().batch();
    snapshot.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
  }
);
```

- [ ] **Step 2: Commit**

```bash
cd /Users/macbookpro/StudioProjects/usta_book
git add functions/src/triggers/onAppointmentDeleted.ts
git commit -m "feat: add onAppointmentDeleted trigger to clean up notification queue"
```

---

## Task 6: Implement sendSmsReminders scheduled function

**Files:**
- Create: `functions/src/scheduled/sendSmsReminders.ts`
- Create: `functions/src/__tests__/sendSmsReminders.test.ts`

- [ ] **Step 1: Write failing tests**

Create `functions/src/__tests__/sendSmsReminders.test.ts`:
```typescript
import { buildSmsText } from '../scheduled/sendSmsReminders';

describe('buildSmsText', () => {
  it('returns Uzbek text for language "uz"', () => {
    const text = buildSmsText('uz', 'Jasur');
    expect(text).toBe('Hurmatli Jasur, 1 soatdan keyin uchrashuvingiz bor. Usta sizni kutadi!');
  });

  it('returns Russian text for language "ru"', () => {
    const text = buildSmsText('ru', 'Анна');
    expect(text).toBe('Уважаемый(-ая) Анна, через 1 час у вас запись к мастеру. Ждём вас!');
  });

  it('falls back to Russian for unknown language', () => {
    const text = buildSmsText('fr' as any, 'Test');
    expect(text).toBe('Уважаемый(-ая) Test, через 1 час у вас запись к мастеру. Ждём вас!');
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/macbookpro/StudioProjects/usta_book/functions
npm test -- --testPathPattern=sendSmsReminders
```

Expected: FAIL — `Cannot find module '../scheduled/sendSmsReminders'`

- [ ] **Step 3: Implement sendSmsReminders.ts**

Create `functions/src/scheduled/sendSmsReminders.ts`:
```typescript
import * as admin from 'firebase-admin';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { getEskizToken, sendSms } from '../services/eskizService';
import { Language, NotificationQueueDoc } from '../types';

const SMS_TEMPLATES: Record<Language, (name: string) => string> = {
  uz: (name) => `Hurmatli ${name}, 1 soatdan keyin uchrashuvingiz bor. Usta sizni kutadi!`,
  ru: (name) => `Уважаемый(-ая) ${name}, через 1 час у вас запись к мастеру. Ждём вас!`,
};

export function buildSmsText(language: Language, clientName: string): string {
  const template = SMS_TEMPLATES[language] ?? SMS_TEMPLATES['ru'];
  return template(clientName);
}

export const sendSmsReminders = onSchedule(
  { schedule: '* * * * *', timeZone: 'Asia/Tashkent' },
  async () => {
    const now = admin.firestore.Timestamp.now();

    const snapshot = await admin
      .firestore()
      .collection('notification_queue')
      .where('status', '==', 'pending')
      .where('sendAt', '<=', now)
      .get();

    if (snapshot.empty) return;

    const email = process.env.ESKIZ_EMAIL;
    const password = process.env.ESKIZ_PASSWORD;

    if (!email || !password) {
      console.error('ESKIZ_EMAIL or ESKIZ_PASSWORD not set');
      return;
    }

    const token = await getEskizToken(email, password);

    for (const doc of snapshot.docs) {
      const data = doc.data() as NotificationQueueDoc;
      const message = buildSmsText(data.language, data.clientName);

      try {
        await sendSms(token, data.clientPhone, message);
        await doc.ref.update({ status: 'sent' });
      } catch (err: unknown) {
        const errMessage = err instanceof Error ? err.message : 'Unknown error';
        await doc.ref.update({ status: 'failed', error: errMessage });
      }
    }
  }
);
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
cd /Users/macbookpro/StudioProjects/usta_book/functions
npm test -- --testPathPattern=sendSmsReminders
```

Expected: PASS — 3 tests pass.

- [ ] **Step 5: Commit**

```bash
cd /Users/macbookpro/StudioProjects/usta_book
git add functions/src/scheduled/sendSmsReminders.ts functions/src/__tests__/sendSmsReminders.test.ts
git commit -m "feat: add sendSmsReminders scheduled function"
```

---

## Task 7: Wire up index.ts and run all tests

**Files:**
- Create: `functions/src/index.ts`

- [ ] **Step 1: Create index.ts**

Create `functions/src/index.ts`:
```typescript
import * as admin from 'firebase-admin';

admin.initializeApp();

export { onAppointmentCreated } from './triggers/onAppointmentCreated';
export { onAppointmentDeleted } from './triggers/onAppointmentDeleted';
export { sendSmsReminders } from './scheduled/sendSmsReminders';
```

- [ ] **Step 2: Run all tests**

```bash
cd /Users/macbookpro/StudioProjects/usta_book/functions
npm test
```

Expected:
```
PASS src/__tests__/eskizService.test.ts
PASS src/__tests__/onAppointmentCreated.test.ts
PASS src/__tests__/sendSmsReminders.test.ts

Test Suites: 3 passed, 3 total
Tests:       12 passed, 12 total
```

- [ ] **Step 3: Build TypeScript**

```bash
cd /Users/macbookpro/StudioProjects/usta_book/functions
npm run build
```

Expected: `lib/` directory created, no TypeScript errors.

- [ ] **Step 4: Commit**

```bash
cd /Users/macbookpro/StudioProjects/usta_book
git add functions/src/index.ts
git commit -m "feat: wire up Cloud Functions index.ts"
```

---

## Task 8: Update firebase.json and deploy

**Files:**
- Modify: `firebase.json`

- [ ] **Step 1: Update firebase.json to include functions**

Open `firebase.json` and replace its content with:
```json
{
  "functions": [
    {
      "source": "functions",
      "codebase": "default",
      "ignore": ["node_modules", ".git", "firebase-debug.log", "firebase-debug.*.log", "*.local"]
    }
  ],
  "flutter": {
    "platforms": {
      "android": {
        "default": {
          "projectId": "ustabook-c00e4",
          "appId": "1:481994759203:android:dbf842562356fc76bbe596",
          "fileOutput": "android/app/google-services.json"
        }
      },
      "ios": {
        "default": {
          "projectId": "ustabook-c00e4",
          "appId": "1:481994759203:ios:e5c2185ecab624abbbe596",
          "uploadDebugSymbols": false,
          "fileOutput": "ios/Runner/GoogleService-Info.plist"
        }
      },
      "dart": {
        "lib/firebase_options.dart": {
          "projectId": "ustabook-c00e4",
          "configurations": {
            "android": "1:481994759203:android:dbf842562356fc76bbe596",
            "ios": "1:481994759203:ios:e5c2185ecab624abbbe596"
          }
        }
      }
    }
  }
}
```

- [ ] **Step 2: Set Eskiz credentials as Firebase environment variables**

```bash
cd /Users/macbookpro/StudioProjects/usta_book
firebase functions:secrets:set ESKIZ_EMAIL
# Enter your Eskiz email when prompted

firebase functions:secrets:set ESKIZ_PASSWORD
# Enter your Eskiz password when prompted
```

> Or use `.env` file in `functions/` for local emulator testing.

- [ ] **Step 3: Deploy**

```bash
cd /Users/macbookpro/StudioProjects/usta_book
firebase deploy --only functions
```

Expected output:
```
✔  functions[onAppointmentCreated]: Successful create operation.
✔  functions[onAppointmentDeleted]: Successful create operation.
✔  functions[sendSmsReminders]: Successful create operation.
✔  Deploy complete!
```

- [ ] **Step 4: Commit firebase.json**

```bash
cd /Users/macbookpro/StudioProjects/usta_book
git add firebase.json
git commit -m "chore: update firebase.json to include functions config"
```

---

## Verification

After deploy, test end-to-end:

1. Open Firebase Console → Firestore → create a document at `masters/{your-uid}/appointments/{test-id}` with:
   ```json
   {
     "clientName": "Test Mijoz",
     "clientPhone": "+998901234567",
     "dateTime": "<timestamp 2 hours from now>",
     "service": "Test",
     "status": "scheduled",
     "createdAt": "<now>"
   }
   ```
2. Check `notification_queue` — a new document should appear with `status: "pending"`.
3. Wait until `sendAt` passes (or manually edit `sendAt` to past time).
4. Within 1 minute, check `notification_queue` — `status` should change to `"sent"`.
5. The client phone should receive an SMS.
