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

// Queue-only kinds (daily summary is not enqueued)
export type PushKind = 'reminder_1h' | 'reminder_15m';

// Kinds carried in the FCM data payload (broader than queue)
export type PushPayloadKind = PushKind | 'daily_summary';

export type PushStatus = 'pending' | 'sent' | 'failed' | 'cancelled';

export interface PushQueueDoc {
  appointmentId: string;
  masterUID: string;
  kind: PushKind;
  sendAt: Timestamp;
  status: PushStatus;
  language: Language;
  error: string | null;
}

export interface FcmToken {
  token: string;
  platform: 'ios' | 'android';
  createdAt: Timestamp;
  lastSeenAt: Timestamp;
}

export interface PushSettings {
  reminderOneHour: boolean;
  reminderFifteenMin: boolean;
  dailySummary: boolean;
  dailySummaryTime: string; // 'HH:MM'
  timezone: string;         // IANA, e.g. 'Asia/Tashkent'
}

export const DEFAULT_PUSH_SETTINGS: PushSettings = {
  reminderOneHour: true,
  reminderFifteenMin: true,
  dailySummary: true,
  dailySummaryTime: '08:00',
  timezone: 'Asia/Tashkent',
};

export interface FcmPayload {
  notification: { title: string; body: string };
  data: { kind: PushPayloadKind; appointmentId: string };
  android: { priority: 'high'; notification: { channelId: string; sound: string } };
  apns: { payload: { aps: { sound: string } } };
}
