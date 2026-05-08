import * as admin from 'firebase-admin';

const TOP_CLIENTS_LIMIT = 20;

interface ClientAgg {
  name: string;
  phone: string;
  visits: number;
  lastVisitMs: number;
  totalSpent: number;
}

function parseRecordDate(dateStr: unknown, timeStr: unknown): Date | null {
  if (typeof dateStr !== 'string' || !dateStr) return null;
  const m = /^(\d{2})\/(\d{2})\/(\d{4})$/.exec(dateStr.trim());
  if (!m) return null;
  const day = parseInt(m[1], 10);
  const month = parseInt(m[2], 10);
  const year = parseInt(m[3], 10);
  let hour = 0;
  let minute = 0;
  if (typeof timeStr === 'string' && timeStr) {
    const tm = /^(\d{1,2}):(\d{2})$/.exec(timeStr.trim());
    if (tm) {
      hour = parseInt(tm[1], 10);
      minute = parseInt(tm[2], 10);
    }
  }
  const d = new Date(year, month - 1, day, hour, minute);
  return isNaN(d.getTime()) ? null : d;
}

function parsePrice(p: unknown): number {
  if (typeof p === 'number') return isFinite(p) ? p : 0;
  if (typeof p === 'string') {
    const cleaned = p.replace(/[^0-9.\-]/g, '');
    const n = parseFloat(cleaned);
    return isFinite(n) ? n : 0;
  }
  return 0;
}

function currentMonthKey(now: Date = new Date()): string {
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
}

function monthKeyOf(date: Date): string {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
}

export async function recomputeMasterStats(masterUID: string): Promise<void> {
  const db = admin.firestore();
  const recordsSnap = await db
    .collection('masters')
    .doc(masterUID)
    .collection('records')
    .get();

  const monthKey = currentMonthKey();
  let monthlyOrders = 0;
  let monthlyRevenue = 0;

  const clientMap = new Map<string, ClientAgg>();
  const serviceMap = new Map<string, number>();

  for (const doc of recordsSnap.docs) {
    const data = doc.data();
    const status = typeof data.status === 'string' ? data.status : '';
    if (status === 'cancelled') continue;

    const recordDate = parseRecordDate(data.date, data.time);
    const price = parsePrice(data.price);

    if (recordDate && monthKeyOf(recordDate) === monthKey) {
      monthlyOrders++;
      monthlyRevenue += price;
    }

    const phone = (typeof data.client_number === 'string' ? data.client_number : '').trim();
    const name = (typeof data.client_name === 'string' ? data.client_name : '').trim();
    const key = phone || name;
    if (key) {
      const cur: ClientAgg = clientMap.get(key) || {
        name,
        phone,
        visits: 0,
        lastVisitMs: 0,
        totalSpent: 0,
      };
      cur.visits++;
      cur.totalSpent += price;
      if (recordDate && recordDate.getTime() > cur.lastVisitMs) {
        cur.lastVisitMs = recordDate.getTime();
      }
      if (name) cur.name = name;
      clientMap.set(key, cur);
    }

    const service = (typeof data.service_type === 'string' ? data.service_type : '').trim();
    if (service) {
      serviceMap.set(service, (serviceMap.get(service) || 0) + 1);
    }
  }

  const totalClients = clientMap.size;
  const returningClients = [...clientMap.values()].filter((c) => c.visits > 1).length;
  const retentionRate =
    totalClients > 0 ? Math.round((returningClients / totalClients) * 100) : 0;

  const topClients = [...clientMap.values()]
    .sort((a, b) => b.visits - a.visits || b.lastVisitMs - a.lastVisitMs)
    .slice(0, TOP_CLIENTS_LIMIT)
    .map((c) => ({
      name: c.name,
      phone: c.phone,
      visits: c.visits,
      lastVisit:
        c.lastVisitMs > 0 ? admin.firestore.Timestamp.fromMillis(c.lastVisitMs) : null,
      totalSpent: c.totalSpent,
    }));

  const topServiceEntry = [...serviceMap.entries()].sort((a, b) => b[1] - a[1])[0];
  const topService = topServiceEntry
    ? { name: topServiceEntry[0], count: topServiceEntry[1] }
    : null;

  const avgBill = monthlyOrders > 0 ? Math.round(monthlyRevenue / monthlyOrders) : 0;

  await db
    .collection('masters')
    .doc(masterUID)
    .collection('stats')
    .doc('summary')
    .set({
      month: monthKey,
      monthlyOrders,
      monthlyRevenue,
      avgBill,
      totalClients,
      returningClients,
      retentionRate,
      topClients,
      topService,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}
