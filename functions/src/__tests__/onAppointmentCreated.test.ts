import { Timestamp } from 'firebase-admin/firestore';
import { buildNotification } from '../triggers/onAppointmentCreated';

describe('buildNotification', () => {
  const masterUID = 'master-1';
  const appointmentId = 'appt-1';
  const clientName = 'Ali';
  const clientPhone = '+998901234567';
  const language = 'uz';

  it('sets sendAt to 1 hour before appointment', () => {
    const apptTime = new Date(Date.now() + 3 * 60 * 60 * 1000); // 3h from now
    const expectedSendAt = new Date(apptTime.getTime() - 60 * 60 * 1000);
    const result = buildNotification(
      masterUID,
      appointmentId,
      { clientName, clientPhone, dateTime: Timestamp.fromDate(apptTime) },
      language
    );

    expect(result!.sendAt.toDate().getTime()).toBe(expectedSendAt.getTime());
  });

  it('returns null if appointment is less than 1 hour from now', () => {
    const soon = new Date(Date.now() + 30 * 60 * 1000); // 30 min from now
    const result = buildNotification(
      masterUID,
      appointmentId,
      { clientName, clientPhone, dateTime: Timestamp.fromDate(soon) },
      language
    );

    expect(result).toBeNull();
  });

  it('sets status to pending', () => {
    const apptTime = new Date(Date.now() + 3 * 60 * 60 * 1000); // 3h from now
    const result = buildNotification(
      masterUID,
      appointmentId,
      { clientName, clientPhone, dateTime: Timestamp.fromDate(apptTime) },
      language
    );

    expect(result!.status).toBe('pending');
    expect(result!.error).toBeNull();
  });

  it('maps language "RU" to "ru"', () => {
    const apptTime = new Date(Date.now() + 3 * 60 * 60 * 1000);
    const result = buildNotification(
      masterUID,
      appointmentId,
      { clientName, clientPhone, dateTime: Timestamp.fromDate(apptTime) },
      'RU'
    );

    expect(result!.language).toBe('ru');
  });

  it('maps language "UZ" to "uz"', () => {
    const apptTime = new Date(Date.now() + 3 * 60 * 60 * 1000);
    const result = buildNotification(
      masterUID,
      appointmentId,
      { clientName, clientPhone, dateTime: Timestamp.fromDate(apptTime) },
      'UZ'
    );

    expect(result!.language).toBe('uz');
  });
});
