import { onDocumentDeleted } from 'firebase-functions/v2/firestore';
import { recomputeMasterStats } from '../services/statsAggregator';

export const onRecordDeleted = onDocumentDeleted(
  'masters/{masterUID}/records/{recordId}',
  async (event) => {
    const { masterUID } = event.params;
    try {
      await recomputeMasterStats(masterUID);
    } catch (err) {
      console.error(`Failed to recompute stats for master ${masterUID}:`, err);
    }
  }
);
