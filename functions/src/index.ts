import * as admin from 'firebase-admin';

admin.initializeApp();

export { onAppointmentCreated } from './triggers/onAppointmentCreated';
export { onAppointmentDeleted } from './triggers/onAppointmentDeleted';
export { sendSmsReminders } from './scheduled/sendSmsReminders';
