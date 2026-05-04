import { Timestamp } from 'firebase-admin/firestore';
import { dateTimeChanged } from '../triggers/onAppointmentUpdated';

const t = (ms: number) => Timestamp.fromMillis(ms);

describe('dateTimeChanged', () => {
  const base = { clientName: 'Ali', clientPhone: '+998', dateTime: t(1000) };

  it('returns true when dateTime differs', () => {
    expect(dateTimeChanged(base, { ...base, dateTime: t(2000) })).toBe(true);
  });

  it('returns false when dateTime is identical', () => {
    expect(dateTimeChanged(base, { ...base, clientName: 'Vali' })).toBe(false);
  });

  it('returns false when before/after are missing', () => {
    expect(dateTimeChanged(undefined, base)).toBe(false);
    expect(dateTimeChanged(base, undefined)).toBe(false);
  });
});
