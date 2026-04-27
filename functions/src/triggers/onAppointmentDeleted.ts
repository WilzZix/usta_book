import * as admin from 'firebase-admin';
import { onDocumentDeleted } from 'firebase-functions/v2/firestore';

export const onAppointmentDeleted = onDocumentDeleted(
  'masters/{masterUID}/appointments/{appointmentId}',
  async (event) => {
    const { appointmentId } = event.params;

    try {
      const snapshot = await admin
        .firestore()
        .collection('notification_queue')
        .where('appointmentId', '==', appointmentId)
        .where('status', '==', 'pending')
        .get();

      if (snapshot.empty) return;

      const BATCH_LIMIT = 500;
      const docs = snapshot.docs;
      for (let i = 0; i < docs.length; i += BATCH_LIMIT) {
        const batch = admin.firestore().batch();
        docs.slice(i, i + BATCH_LIMIT).forEach((doc) => batch.delete(doc.ref));
        await batch.commit();
      }
    } catch (err) {
      console.error(`Failed to clean up notifications for appointment ${appointmentId}:`, err);
    }
  }
);
