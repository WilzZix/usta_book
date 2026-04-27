import axios from 'axios';

const BASE = 'https://notify.eskiz.uz/api';

export async function getEskizToken(email: string, password: string): Promise<string> {
  const res = await axios.post(`${BASE}/auth/login`, { email, password });
  return res.data.data.token as string;
}

export async function sendSms(token: string, phone: string, message: string): Promise<void> {
  await axios.post(
    `${BASE}/message/sms/send`,
    { mobile_phone: phone, message, from: '4546' },
    { headers: { Authorization: `Bearer ${token}` } }
  );
}
