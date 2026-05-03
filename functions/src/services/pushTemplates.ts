import { AppointmentData, FcmPayload, Language, PushKind } from '../types';

const CHANNEL_ID = 'reminders';

export function pluralizeRu(n: number, [one, few, many]: [string, string, string]): string {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod100 >= 11 && mod100 <= 14) return many;
  if (mod10 === 1) return one;
  if (mod10 >= 2 && mod10 <= 4) return few;
  return many;
}

function basePayload(title: string, body: string, kind: 'reminder_1h' | 'reminder_15m' | 'daily_summary', appointmentId: string): FcmPayload {
  return {
    notification: { title, body },
    data: { kind, appointmentId },
    android: { priority: 'high', notification: { channelId: CHANNEL_ID, sound: 'default' } },
    apns: { payload: { aps: { sound: 'default' } } },
  };
}

export function buildReminderPayload(
  kind: PushKind,
  language: Language,
  apt: AppointmentData,
  appointmentId: string
): FcmPayload {
  let title: string;
  let body: string;

  if (kind === 'reminder_1h') {
    if (language === 'uz') {
      title = 'Yaqin yozuv';
      body = `1 soatdan keyin: ${apt.clientName} (${apt.clientPhone})`;
    } else {
      title = 'Скоро запись';
      body = `Через 1 час: ${apt.clientName} (${apt.clientPhone})`;
    }
  } else {
    if (language === 'uz') {
      title = '15 daqiqa qoldi';
      body = `${apt.clientName} bilan uchrashuvga 15 daqiqa qoldi`;
    } else {
      title = 'Осталось 15 минут';
      body = `До встречи с ${apt.clientName} осталось 15 минут`;
    }
  }

  return basePayload(title, body, kind, appointmentId);
}

function formatHM(date: Date, timezone: string): string {
  const fmt = new Intl.DateTimeFormat('en-GB', {
    hour: '2-digit', minute: '2-digit', hour12: false, timeZone: timezone,
  });
  return fmt.format(date);
}

export function buildDailySummaryPayload(
  language: Language,
  appointmentsToday: AppointmentData[],
  timezone: string = 'Asia/Tashkent'
): FcmPayload {
  const n = appointmentsToday.length;

  if (n === 0) {
    const [title, body] = language === 'uz'
      ? ["Bugun bo'sh kun", "Yozuvingiz yo'q — yaxshi dam oling"]
      : ['Сегодня свободный день', 'Записей нет — хорошего отдыха'];
    return basePayload(title, body, 'daily_summary', '');
  }

  const sorted = [...appointmentsToday].sort(
    (a, b) => a.dateTime.toMillis() - b.dateTime.toMillis()
  );
  const first = sorted[0];
  const firstHM = formatHM(first.dateTime.toDate(), timezone);

  let title: string;
  let body: string;

  if (language === 'uz') {
    title = `Bugun ${n} ta yozuv`;
    body = `Birinchi yozuv: ${firstHM} — ${first.clientName}`;
  } else {
    const word = pluralizeRu(n, ['запись', 'записи', 'записей']);
    title = `Сегодня ${n} ${word}`;
    body = `Первая: ${firstHM} — ${first.clientName}`;
  }

  return basePayload(title, body, 'daily_summary', '');
}
