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
