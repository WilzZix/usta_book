import * as admin from 'firebase-admin';

admin.initializeApp();

export { onAppointmentCreated } from './triggers/onAppointmentCreated';
export { onAppointmentDeleted } from './triggers/onAppointmentDeleted';
export { onAppointmentUpdated } from './triggers/onAppointmentUpdated';
export { onRecordCreated } from './triggers/onRecordCreated';
export { onRecordUpdated } from './triggers/onRecordUpdated';
export { onRecordDeleted } from './triggers/onRecordDeleted';
export { sendSmsReminders } from './scheduled/sendSmsReminders';
export { sendPushReminders } from './scheduled/sendPushReminders';
export { sendDailySummaries } from './scheduled/sendDailySummaries';
