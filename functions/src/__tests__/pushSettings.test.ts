import { extractPushSettings } from '../services/pushSettings';
import { DEFAULT_PUSH_SETTINGS } from '../types';

describe('extractPushSettings', () => {
  it('returns defaults when masterDoc is undefined', () => {
    expect(extractPushSettings(undefined)).toEqual(DEFAULT_PUSH_SETTINGS);
  });
  it('returns defaults when pushSettings field absent', () => {
    expect(extractPushSettings({ language: 'uz' })).toEqual(DEFAULT_PUSH_SETTINGS);
  });
  it('uses provided overrides', () => {
    const result = extractPushSettings({
      pushSettings: { reminderOneHour: false, dailySummaryTime: '07:30' },
    });
    expect(result.reminderOneHour).toBe(false);
    expect(result.dailySummaryTime).toBe('07:30');
    expect(result.dailySummary).toBe(DEFAULT_PUSH_SETTINGS.dailySummary);
  });
});
