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
