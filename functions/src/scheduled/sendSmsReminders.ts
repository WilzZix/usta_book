import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { getEskizToken, sendSms } from '../services/eskizService';
import { Language, NotificationQueueDoc } from '../types';

const SMS_TEMPLATES: Record<Language, (name: string) => string> = {
  uz: (name) => `Hurmatli ${name}, 1 soatdan keyin uchrashuvingiz bor. Usta sizni kutadi!`,
  ru: (name) => `Уважаемый(-ая) ${name}, через 1 час у вас запись к мастеру. Ждём вас!`,
};

export function buildSmsText(language: Language, clientName: string): string {
  const template = SMS_TEMPLATES[language] ?? SMS_TEMPLATES['ru'];
  return template(clientName);
}

export const sendSmsReminders = onSchedule(
  { schedule: '* * * * *', timeZone: 'Asia/Tashkent' },
  async () => {
    const now = Timestamp.now();

    const snapshot = await admin
      .firestore()
      .collection('notification_queue')
      .where('status', '==', 'pending')
      .where('sendAt', '<=', now)
      .get();

    if (snapshot.empty) return;

    const email = process.env.ESKIZ_EMAIL;
    const password = process.env.ESKIZ_PASSWORD;

    if (!email || !password) {
      console.error('ESKIZ_EMAIL or ESKIZ_PASSWORD not set');
      return;
    }

    let token: string;
    try {
      token = await getEskizToken(email, password);
    } catch (err) {
      console.error('Failed to get Eskiz token:', err);
      return;
    }

    for (const doc of snapshot.docs) {
      const data = doc.data() as NotificationQueueDoc;
      const message = buildSmsText(data.language, data.clientName);

      try {
        await sendSms(token, data.clientPhone, message);
        await doc.ref.update({ status: 'sent' });
      } catch (err: unknown) {
        const errMessage = err instanceof Error ? err.message : 'Unknown error';
        await doc.ref.update({ status: 'failed', error: errMessage });
      }
    }
  }
);
