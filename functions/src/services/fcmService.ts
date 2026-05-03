import * as admin from 'firebase-admin';
import { FcmPayload } from '../types';

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
    tokenIds.push(d.id);
    tokens.push(d.data().token as string);
  });

  const message: admin.messaging.MulticastMessage = {
    tokens,
    notification: payload.notification,
    data: payload.data as Record<string, string>,
    android: payload.android as admin.messaging.AndroidConfig,
    apns: payload.apns as admin.messaging.ApnsConfig,
  };

  const result = await admin.messaging().sendEachForMulticast(message);
  const invalidIds = extractInvalidTokenIds(result.responses, tokenIds);

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
    successCount: result.successCount,
    failureCount: result.failureCount,
    invalidatedTokens: invalidIds,
  };
}
