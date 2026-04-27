import axios from 'axios';
import { getEskizToken, sendSms } from '../services/eskizService';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

beforeEach(() => jest.clearAllMocks());

describe('getEskizToken', () => {
  it('returns token from Eskiz response', async () => {
    mockedAxios.post.mockResolvedValueOnce({
      data: { data: { token: 'abc123' } },
    });

    const token = await getEskizToken('user@test.com', 'secret');

    expect(token).toBe('abc123');
    expect(mockedAxios.post).toHaveBeenCalledTimes(1);
    expect(mockedAxios.post).toHaveBeenCalledWith(
      'https://notify.eskiz.uz/api/auth/login',
      { email: 'user@test.com', password: 'secret' }
    );
  });

  it('throws if axios call fails', async () => {
    mockedAxios.post.mockRejectedValueOnce(new Error('Network error'));
    await expect(getEskizToken('u@t.com', 'p')).rejects.toThrow('Network error');
  });
});

describe('sendSms', () => {
  it('sends POST with correct payload and auth header', async () => {
    mockedAxios.post.mockResolvedValueOnce({ data: {} });

    await sendSms('my-token', '+998901234567', 'Hello');

    expect(mockedAxios.post).toHaveBeenCalledTimes(1);
    expect(mockedAxios.post).toHaveBeenCalledWith(
      'https://notify.eskiz.uz/api/message/sms/send',
      { mobile_phone: '+998901234567', message: 'Hello', from: '4546' },
      { headers: { Authorization: 'Bearer my-token' } }
    );
  });

  it('throws on API error', async () => {
    mockedAxios.post.mockRejectedValueOnce(new Error('401 Unauthorized'));
    await expect(sendSms('bad-token', '+998901234567', 'msg')).rejects.toThrow('401 Unauthorized');
  });
});
