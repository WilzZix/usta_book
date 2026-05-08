import * as admin from 'firebase-admin';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { recomputeMasterStats } from '../services/statsAggregator';

export const onRecordCreated = onDocumentCreated(
  'masters/{masterUID}/records/{recordId}',
  async (event) => {
    const { masterUID } = event.params;
    const db = admin.firestore();

    try {
      const masterRef = db.collection('masters').doc(masterUID);
      const masterSnap = await masterRef.get();
      if (!masterSnap.get('trialStartedAt')) {
        await masterRef.set(
          { trialStartedAt: admin.firestore.FieldValue.serverTimestamp() },
          { merge: true }
        );
      }
    } catch (err) {
      console.error(`Failed to set trialStartedAt for master ${masterUID}:`, err);
    }

    try {
      await recomputeMasterStats(masterUID);
    } catch (err) {
      console.error(`Failed to recompute stats for master ${masterUID}:`, err);
    }
  }
);
