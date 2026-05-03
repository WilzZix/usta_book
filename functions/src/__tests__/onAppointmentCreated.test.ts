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

import { buildPushQueueDocs } from '../triggers/onAppointmentCreated';
import { DEFAULT_PUSH_SETTINGS } from '../types';

describe('buildPushQueueDocs', () => {
  const masterUID = 'm1';
  const appointmentId = 'a1';
  const apt = (offsetMs: number) => ({
    clientName: 'Ali',
    clientPhone: '+998',
    dateTime: Timestamp.fromDate(new Date(Date.now() + offsetMs)),
  });

  it('returns 1h and 15m docs when both toggles on and times are future', () => {
    const docs = buildPushQueueDocs(masterUID, appointmentId, apt(3 * 3600 * 1000), 'uz', DEFAULT_PUSH_SETTINGS);
    expect(docs).toHaveLength(2);
    expect(docs.map((d) => d.kind).sort()).toEqual(['reminder_15m', 'reminder_1h']);
    expect(docs.every((d) => d.status === 'pending')).toBe(true);
    expect(docs.every((d) => d.masterUID === masterUID)).toBe(true);
  });

  it('skips reminder_1h when 1h-window has already passed', () => {
    const docs = buildPushQueueDocs(masterUID, appointmentId, apt(30 * 60 * 1000), 'uz', DEFAULT_PUSH_SETTINGS);
    expect(docs.map((d) => d.kind)).toEqual(['reminder_15m']);
  });

  it('skips both when appointment is in the past', () => {
    const docs = buildPushQueueDocs(masterUID, appointmentId, apt(-60_000), 'uz', DEFAULT_PUSH_SETTINGS);
    expect(docs).toHaveLength(0);
  });

  it('respects reminderOneHour toggle off', () => {
    const settings = { ...DEFAULT_PUSH_SETTINGS, reminderOneHour: false };
    const docs = buildPushQueueDocs(masterUID, appointmentId, apt(3 * 3600 * 1000), 'uz', settings);
    expect(docs.map((d) => d.kind)).toEqual(['reminder_15m']);
  });

  it('respects reminderFifteenMin toggle off', () => {
    const settings = { ...DEFAULT_PUSH_SETTINGS, reminderFifteenMin: false };
    const docs = buildPushQueueDocs(masterUID, appointmentId, apt(3 * 3600 * 1000), 'uz', settings);
    expect(docs.map((d) => d.kind)).toEqual(['reminder_1h']);
  });

  it('returns docId-friendly suffix in returned tuple', () => {
    const docs = buildPushQueueDocs(masterUID, appointmentId, apt(3 * 3600 * 1000), 'uz', DEFAULT_PUSH_SETTINGS);
    const ids = docs.map((d) => d.docId);
    expect(ids).toContain('a1_1h');
    expect(ids).toContain('a1_15m');
  });
});
