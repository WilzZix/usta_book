import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { sendPushToMaster } from '../services/fcmService';
import { extractPushSettings } from '../services/pushSettings';
import { buildReminderPayload } from '../services/pushTemplates';
import {
  AppointmentData,
  PushKind,
  PushQueueDoc,
  PushSettings,
} from '../types';

export function shouldStillSend(kind: PushKind, settings: PushSettings): boolean {
  if (kind === 'reminder_1h') return settings.reminderOneHour;
  return settings.reminderFifteenMin;
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
