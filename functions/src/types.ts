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
