import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { recomputeMasterStats } from '../services/statsAggregator';

const RELEVANT_FIELDS = ['price', 'date', 'time', 'status', 'client_name', 'client_number', 'service_type'];

export const onRecordUpdated = onDocumentUpdated(
  'masters/{masterUID}/records/{recordId}',
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    const changed = RELEVANT_FIELDS.some((f) => before[f] !== after[f]);
    if (!changed) return;

    const { masterUID } = event.params;
    try {
      await recomputeMasterStats(masterUID);
    } catch (err) {
      console.error(`Failed to recompute stats for master ${masterUID}:`, err);
    }
  }
);
