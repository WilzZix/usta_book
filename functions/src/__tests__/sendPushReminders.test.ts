import { shouldStillSend } from '../scheduled/sendPushReminders';
import { DEFAULT_PUSH_SETTINGS } from '../types';

describe('shouldStillSend', () => {
  it('returns true when reminder_1h and toggle on', () => {
    expect(shouldStillSend('reminder_1h', DEFAULT_PUSH_SETTINGS)).toBe(true);
  });
  it('returns false when reminder_1h and toggle off', () => {
    expect(shouldStillSend('reminder_1h', { ...DEFAULT_PUSH_SETTINGS, reminderOneHour: false })).toBe(false);
  });
  it('returns true when reminder_15m and toggle on', () => {
    expect(shouldStillSend('reminder_15m', DEFAULT_PUSH_SETTINGS)).toBe(true);
  });
  it('returns false when reminder_15m and toggle off', () => {
    expect(shouldStillSend('reminder_15m', { ...DEFAULT_PUSH_SETTINGS, reminderFifteenMin: false })).toBe(false);
  });
});
