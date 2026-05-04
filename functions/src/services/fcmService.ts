import * as admin from 'firebase-admin';
import { FcmPayload, FcmToken } from '../types';

const FCM_MAX_BATCH_SIZE = 500;

export function chunk<T>(arr: T[], size: number): T[][] {
  if (size <= 0) throw new Error('chunk size must be positive');
  const out: T[][] = [];
  for (let i = 0; i < arr.length; i += size) {
    out.push(arr.slice(i, i + size));
  }
  return out;
}

export interface SendResult {
  successCount: number;
  failureCount: number;
  invalidatedTokens: string[];
}

export function extractInvalidTokenIds(
  responses: admin.messaging.SendResponse[],
  tokenIds: string[]
): string[] {
  const invalid: string[] = [];
  responses.forEach((r, i) => {
    if (!r.success && r.error?.code === 'messaging/registration-token-not-registered') {
      invalid.push(tokenIds[i]);
    }
  });
  return invalid;
}

export async function sendPushToMaster(
  masterUID: string,
  payload: FcmPayload
): Promise<SendResult> {
  const tokensSnap = await admin
    .firestore()
    .collection('masters')
    .doc(masterUID)
    .collection('fcmTokens')
    .get();

  if (tokensSnap.empty) {
    return { successCount: 0, failureCount: 0, invalidatedTokens: [] };
  }

  const tokenIds: string[] = [];
  const tokens: string[] = [];
  tokensSnap.docs.forEach((d) => {
    const data = d.data() as FcmToken;
    tokenIds.push(d.id);
    tokens.push(data.token);
  });

  let successCount = 0;
  let failureCount = 0;
  const allResponses: admin.messaging.SendResponse[] = [];

  for (const chunkTokens of chunk(tokens, FCM_MAX_BATCH_SIZE)) {
    const message: admin.messaging.MulticastMessage = {
      tokens: chunkTokens,
      notification: payload.notification,
      data: payload.data as Record<string, string>,
      android: payload.android as admin.messaging.AndroidConfig,
      apns: payload.apns as admin.messaging.ApnsConfig,
    };
    const result = await admin.messaging().sendEachForMulticast(message);
    successCount += result.successCount;
    failureCount += result.failureCount;
    allResponses.push(...result.responses);
  }

  const invalidIds = extractInvalidTokenIds(allResponses, tokenIds);

  if (invalidIds.length > 0) {
    const batch = admin.firestore().batch();
    invalidIds.forEach((id) =>
      batch.delete(
        admin.firestore().collection('masters').doc(masterUID).collection('fcmTokens').doc(id)
      )
    );
    await batch.commit();
  }

  return {
    successCount,
    failureCount,
    invalidatedTokens: invalidIds,
  };
}
