import { Timestamp } from 'firebase-admin/firestore';
import {
  buildReminderPayload,
  buildDailySummaryPayload,
  pluralizeRu,
} from '../services/pushTemplates';

const at = (h: number, m: number) =>
  Timestamp.fromDate(new Date(Date.UTC(2026, 4, 3, h, m)));

describe('pluralizeRu', () => {
  it.each([
    [1, 'запись'],
    [2, 'записи'],
    [3, 'записи'],
    [4, 'записи'],
    [5, 'записей'],
    [11, 'записей'],
    [21, 'запись'],
    [25, 'записей'],
  ])('returns correct form for %i', (n, expected) => {
    expect(pluralizeRu(n, ['запись', 'записи', 'записей'])).toBe(expected);
  });
});

describe('buildReminderPayload', () => {
  const apt = { clientName: 'Ali', clientPhone: '+998901234567', dateTime: at(10, 0) };

  it('builds Uzbek 1h reminder', () => {
    const p = buildReminderPayload('reminder_1h', 'uz', apt, 'apt-1');
    expect(p.notification.title).toBe('Yaqin yozuv');
    expect(p.notification.body).toContain('Ali');
    expect(p.notification.body).toContain('+998901234567');
    expect(p.data.kind).toBe('reminder_1h');
    expect(p.data.appointmentId).toBe('apt-1');
    expect(p.android.notification.channelId).toBe('reminders');
  });

  it('builds Russian 15m reminder', () => {
    const p = buildReminderPayload('reminder_15m', 'ru', apt, 'apt-1');
    expect(p.notification.title).toBe('Осталось 15 минут');
    expect(p.notification.body).toContain('Ali');
  });
});

describe('buildDailySummaryPayload', () => {
  it('returns free-day template when N=0 (uz)', () => {
    const p = buildDailySummaryPayload('uz', []);
    expect(p.notification.title).toBe("Bugun bo'sh kun");
    expect(p.data.kind).toBe('daily_summary');
    expect(p.data.appointmentId).toBe('');
  });

  it('returns free-day template when N=0 (ru)', () => {
    const p = buildDailySummaryPayload('ru', []);
    expect(p.notification.title).toBe('Сегодня свободный день');
  });

  it('returns count + first appointment (uz)', () => {
    const list = [
      { clientName: 'Ali', clientPhone: '+998', dateTime: at(9, 30) },
      { clientName: 'Vali', clientPhone: '+998', dateTime: at(11, 0) },
    ];
    const p = buildDailySummaryPayload('uz', list);
    expect(p.notification.title).toBe('Bugun 2 ta yozuv');
    expect(p.notification.body).toContain('Ali');
  });

  it('uses Russian pluralization', () => {
    const list = [
      { clientName: 'Анна', clientPhone: '+998', dateTime: at(9, 0) },
    ];
    const p = buildDailySummaryPayload('ru', list);
    expect(p.notification.title).toBe('Сегодня 1 запись');
  });

  it('uses записи for 2-4 (ru)', () => {
    const list = Array.from({ length: 3 }, (_, i) => ({
      clientName: `c${i}`,
      clientPhone: '+998',
      dateTime: at(9 + i, 0),
    }));
    const p = buildDailySummaryPayload('ru', list);
    expect(p.notification.title).toBe('Сегодня 3 записи');
  });
});
