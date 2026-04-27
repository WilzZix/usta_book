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
