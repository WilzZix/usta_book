import * as admin from 'firebase-admin';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { sendPushToMaster } from '../services/fcmService';
import { extractPushSettings } from '../services/pushSettings';
import { buildDailySummaryPayload } from '../services/pushTemplates';
import { AppointmentData, Language } from '../types';

const WINDOW_MINUTES = 7;

function localTimeParts(timezone: string, now: Date): { hh: number; mm: number; date: string } {
  // 'en-GB' gives 24h. We use parts to extract HH:MM and YYYY-MM-DD reliably.
  const fmt = new Intl.DateTimeFormat('en-GB', {
    hour: '2-digit', minute: '2-digit', hour12: false,
    year: 'numeric', month: '2-digit', day: '2-digit',
    timeZone: timezone,
  });
  const parts = fmt.formatToParts(now);
  const get = (t: string) => parts.find((p) => p.type === t)?.value ?? '';
  const hh = parseInt(get('hour'), 10);
  const mm = parseInt(get('minute'), 10);
  const date = `${get('year')}-${get('month')}-${get('day')}`;
  return { hh, mm, date };
}

export function isWithinSummaryWindow(hhmm: string, timezone: string, now: Date): boolean {
  const [targetH, targetM] = hhmm.split(':').map(Number);
  const { hh, mm } = localTimeParts(timezone, now);
  const nowMin = hh * 60 + mm;
  const targetMin = targetH * 60 + targetM;
  let diff = Math.abs(nowMin - targetMin);
  if (diff > 720) diff = 1440 - diff; // wrap
  return diff <= WINDOW_MINUTES;
}

export function todayKeyForTimezone(timezone: string, now: Date): string {
  const { date } = localTimeParts(timezone, now);
  return date.replace(/-/g, '');
}

async function fetchTodaysAppointments(
  db: FirebaseFirestore.Firestore,
  masterUID: string,
  timezone: string,
  now: Date
): Promise<AppointmentData[]> {
  const { date } = localTimeParts(timezone, now);
  const [y, m, d] = date.split('-').map(Number);
  const fmt = new Intl.DateTimeFormat('en-GB', {
    timeZone: timezone, timeZoneName: 'shortOffset',
  });
  const tzPart = fmt.formatToParts(now).find((p) => p.type === 'timeZoneName')?.value ?? 'GMT+5';
  const match = /GMT([+-])(\d{1,2})(?::(\d{2}))?/.exec(tzPart);
  const sign = match?.[1] === '-' ? -1 : 1;
  const oh = parseInt(match?.[2] ?? '5', 10);
  const om = parseInt(match?.[3] ?? '0', 10);
  const offsetMin = sign * (oh * 60 + om);

  const localMidnightUtcMs = Date.UTC(y, m - 1, d, 0, 0) - offsetMin * 60 * 1000;
  const startTs = admin.firestore.Timestamp.fromMillis(localMidnightUtcMs);
  const endTs = admin.firestore.Timestamp.fromMillis(localMidnightUtcMs + 24 * 3600 * 1000);

  const snap = await db
    .collection('masters')
    .doc(masterUID)
    .collection('appointments')
    .where('dateTime', '>=', startTs)
    .where('dateTime', '<', endTs)
    .get();

  return snap.docs.map((d) => d.data() as AppointmentData);
}

export const sendDailySummaries = onSchedule(
  { schedule: 'every 15 minutes', timeZone: 'Asia/Tashkent' },
  async () => {
    const db = admin.firestore();
    const now = new Date();

    const mastersSnap = await db.collection('masters').get();

    for (const masterDoc of mastersSnap.docs) {
      const settings = extractPushSettings(masterDoc.data());
      if (!settings.dailySummary) continue;
      if (!isWithinSummaryWindow(settings.dailySummaryTime, settings.timezone, now)) continue;

      const masterUID = masterDoc.id;
      const dayKey = todayKeyForTimezone(settings.timezone, now);
      const logRef = db.collection('daily_summary_log').doc(`${masterUID}_${dayKey}`);

      try {
        // Idempotency: only one writer per day
        const claimed = await db.runTransaction(async (tx) => {
          const exist = await tx.get(logRef);
          if (exist.exists) return false;
          tx.set(logRef, {
            masterUID,
            dayKey,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          return true;
        });
        if (!claimed) continue;

        const appts = await fetchTodaysAppointments(db, masterUID, settings.timezone, now);
        const language: Language = (masterDoc.data().language ?? 'ru')
          .toString()
          .toLowerCase() === 'uz' ? 'uz' : 'ru';

        const payload = buildDailySummaryPayload(language, appts, settings.timezone);
        await sendPushToMaster(masterUID, payload);
      } catch (err) {
        console.error(`Daily summary failed for master ${masterUID}:`, err);
      }
    }
  }
);
