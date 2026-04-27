# SMS Reminder Cloud Functions Design

**Date:** 2026-04-27
**Project:** usta_book
**Feature:** Appointment SMS reminder via Eskiz.uz (1 hour before)

---

## Overview

Firebase Cloud Functions that automatically send an SMS to the client 1 hour before their appointment. Uses a `notification_queue` collection to track pending/sent notifications and prevent duplicate messages.

---

## Architecture

Three Cloud Functions:

### 1. `onAppointmentCreated` (Firestore Trigger)
- Trigger: `masters/{masterUID}/appointments/{appointmentId}` → CREATE
- Reads master's `language` field from `masters/{masterUID}`
- Computes `sendAt = appointment.dateTime - 1 hour`
- If `sendAt > now`, creates a document in `notification_queue`
- If appointment is less than 1 hour away, does nothing

### 2. `sendSmsReminders` (Scheduled — every 1 minute)
- Queries `notification_queue` where `status == "pending"` and `sendAt <= now`
- For each result, uses Firestore transaction to atomically mark as processing
- Sends SMS via Eskiz.uz API
- On success: sets `status = "sent"`
- On failure: sets `status = "failed"`, writes error message to `error` field
- No retry logic (prevents spam)

### 3. `onAppointmentDeleted` (Firestore Trigger)
- Trigger: `masters/{masterUID}/appointments/{appointmentId}` → DELETE
- Finds and deletes matching `notification_queue` document
- Prevents SMS being sent for cancelled appointments

---

## Firestore Data Structure

```
notification_queue/{notificationId}
  ├── appointmentId: string
  ├── masterUID: string
  ├── clientName: string
  ├── clientPhone: string       // format: +998XXXXXXXXX
  ├── sendAt: Timestamp         // appointment.dateTime - 1 hour
  ├── language: "uz" | "ru"    // from master profile
  ├── status: "pending" | "sent" | "failed"
  └── error: string | null
```

---

## SMS Messages

- **Uzbek (uz):** `Hurmatli [clientName], 1 soatdan keyin uchrashuvingiz bor. Usta sizni kutadi!`
- **Russian (ru):** `Уважаемый(-ая) [clientName], через 1 час у вас запись к мастеру. Ждём вас!`

Sender ID: `4546` (Eskiz.uz default)

---

## Eskiz.uz Integration

**Auth:**
```
POST https://notify.eskiz.uz/api/auth/login
Body: { email, password }
Response: { data: { token } }
```

**Send SMS:**
```
POST https://notify.eskiz.uz/api/message/sms/send
Headers: Authorization: Bearer <token>
Body: { mobile_phone, message, from: "4546" }
```

Token is fetched fresh before each batch send. If token is expired, re-login is performed automatically.

---

## Project Structure

```
functions/
  ├── src/
  │   ├── index.ts                          // exports all functions
  │   ├── triggers/
  │   │   ├── onAppointmentCreated.ts
  │   │   └── onAppointmentDeleted.ts
  │   ├── scheduled/
  │   │   └── sendSmsReminders.ts
  │   └── services/
  │       └── eskizService.ts               // login + send SMS
  ├── package.json
  └── tsconfig.json
```

---

## Environment Variables

Stored in Firebase Functions config / `.env`:
```
ESKIZ_EMAIL=your@email.com
ESKIZ_PASSWORD=yourpassword
```

---

## Error Handling

| Scenario | Behavior |
|---|---|
| Appointment < 1 hour away | No notification created |
| Eskiz token expired | Re-login, retry once |
| SMS send failure | `status = "failed"`, error logged |
| Appointment deleted before send | notification_queue doc deleted |

---

## Deploy

```bash
cd functions
npm install
firebase deploy --only functions
```

Scheduler cron: `* * * * *` (every minute), region: `us-central1`
