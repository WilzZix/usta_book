import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import {
  AppointmentData,
  Language,
  NotificationQueueDoc,
  PushKind,
  PushQueueDoc,
  PushSettings,
} from '../types';
import { extractPushSettings } from '../services/pushSettings';

const ONE_HOUR_MS = 60 * 60 * 1000;
const FIFTEEN_MIN_MS = 15 * 60 * 1000;

function normaliseLanguage(raw: string): Language {
  return raw.toLowerCase() === 'uz' ? 'uz' : 'ru';
}

export function buildNotification(
  masterUID: string,
  appointmentId: string,
  data: AppointmentData,
  rawLanguage: string
): NotificationQueueDoc | null {
  const apptDate = data.dateTime.toDate();
  const sendAtDate = new Date(apptDate.getTime() - ONE_HOUR_MS);

  if (sendAtDate <= new Date()) return null;

  const language = normaliseLanguage(rawLanguage);

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
  const language = normaliseLanguage(rawLanguage);
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

      const results = await Promise.allSettled(writes);
      results.forEach((r, i) => {
        if (r.status === 'rejected') {
          console.error(`Write ${i} failed for appointment ${appointmentId}:`, r.reason);
        }
      });
    } catch (err) {
      console.error(`Failed to enqueue notifications for appointment ${appointmentId}:`, err);
    }
  }
);
