import { extractInvalidTokenIds } from '../services/fcmService';

describe('extractInvalidTokenIds', () => {
  it('returns ids of responses with not-registered errors', () => {
    const responses = [
      { success: true } as any,
      { success: false, error: { code: 'messaging/registration-token-not-registered' } } as any,
      { success: false, error: { code: 'messaging/invalid-argument' } } as any,
    ];
    const tokenIds = ['t1', 't2', 't3'];
    expect(extractInvalidTokenIds(responses, tokenIds)).toEqual(['t2']);
  });

  it('returns empty array when all succeed', () => {
    const responses = [{ success: true } as any, { success: true } as any];
    expect(extractInvalidTokenIds(responses, ['a', 'b'])).toEqual([]);
  });
});
