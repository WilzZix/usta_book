import { chunk, extractInvalidTokenIds } from '../services/fcmService';

describe('chunk', () => {
  it('splits an array into batches of N', () => {
    expect(chunk([1, 2, 3, 4, 5], 2)).toEqual([[1, 2], [3, 4], [5]]);
  });
  it('returns empty array for empty input', () => {
    expect(chunk([], 100)).toEqual([]);
  });
  it('returns single chunk when input fits', () => {
    expect(chunk([1, 2, 3], 5)).toEqual([[1, 2, 3]]);
  });
  it('throws when size <= 0', () => {
    expect(() => chunk([1], 0)).toThrow();
  });
});

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
