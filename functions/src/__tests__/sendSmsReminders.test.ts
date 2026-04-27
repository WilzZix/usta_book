import { buildSmsText } from '../scheduled/sendSmsReminders';

describe('buildSmsText', () => {
  it('returns Uzbek text for language "uz"', () => {
    const text = buildSmsText('uz', 'Jasur');
    expect(text).toBe('Hurmatli Jasur, 1 soatdan keyin uchrashuvingiz bor. Usta sizni kutadi!');
  });

  it('returns Russian text for language "ru"', () => {
    const text = buildSmsText('ru', 'Анна');
    expect(text).toBe('Уважаемый(-ая) Анна, через 1 час у вас запись к мастеру. Ждём вас!');
  });

  it('falls back to Russian for unknown language', () => {
    const text = buildSmsText('fr' as any, 'Test');
    expect(text).toBe('Уважаемый(-ая) Test, через 1 час у вас запись к мастеру. Ждём вас!');
  });
});
