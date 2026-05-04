import { isWithinSummaryWindow, todayKeyForTimezone } from '../scheduled/sendDailySummaries';

describe('isWithinSummaryWindow', () => {
  // Tashkent is UTC+5 with no DST.
  const tz = 'Asia/Tashkent';

  it('matches when current time is within ±7 minutes of target HH:MM', () => {
    // 08:00 local = 03:00 UTC
    const now = new Date(Date.UTC(2026, 4, 3, 3, 5)); // 08:05 local
    expect(isWithinSummaryWindow('08:00', tz, now)).toBe(true);
  });

  it('rejects when current time is more than 7 minutes from target', () => {
    const now = new Date(Date.UTC(2026, 4, 3, 3, 10)); // 08:10 local
    expect(isWithinSummaryWindow('08:00', tz, now)).toBe(false);
  });

  it('handles midnight wrap', () => {
    const now = new Date(Date.UTC(2026, 4, 2, 18, 58)); // 23:58 local on May 2
    expect(isWithinSummaryWindow('00:00', tz, now)).toBe(true);
  });
});

describe('todayKeyForTimezone', () => {
  it('returns YYYYMMDD in target timezone', () => {
    const now = new Date(Date.UTC(2026, 4, 3, 3, 0)); // 08:00 local Tashkent
    expect(todayKeyForTimezone('Asia/Tashkent', now)).toBe('20260503');
  });

  it('rolls over before UTC midnight when timezone is ahead', () => {
    const now = new Date(Date.UTC(2026, 4, 2, 19, 30)); // 00:30 May 3 local Tashkent
    expect(todayKeyForTimezone('Asia/Tashkent', now)).toBe('20260503');
  });
});
