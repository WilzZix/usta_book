import * as admin from 'firebase-admin';
import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { extractPushSettings } from '../services/pushSettings';
import { AppointmentData } from '../types';
import { buildNotification, buildPushQueueDocs } from './onAppointmentCreated';

export function dateTimeChanged(
  before: AppointmentData | undefined,
  after: AppointmentData | undefined
): boolean {
  if (!before || !after) return false;
  return before.dateTime.toMillis() !== after.dateTime.toMillis();
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
      const results = await Promise.allSettled(writes);
      results.forEach((r, i) => {
        if (r.status === 'rejected') {
          console.error(`Re-enqueue write ${i} failed for appointment ${appointmentId}:`, r.reason);
        }
      });
    } catch (err) {
      console.error(`Failed to re-queue notifications for appointment ${appointmentId}:`, err);
    }
  }
);
