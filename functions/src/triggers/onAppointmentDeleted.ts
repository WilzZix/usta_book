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
