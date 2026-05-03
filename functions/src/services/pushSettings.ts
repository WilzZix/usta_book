import { DEFAULT_PUSH_SETTINGS, PushSettings } from '../types';

export function extractPushSettings(
  masterDoc: FirebaseFirestore.DocumentData | undefined
): PushSettings {
  const raw = masterDoc?.pushSettings;
  if (!raw) return DEFAULT_PUSH_SETTINGS;
  return {
    reminderOneHour: raw.reminderOneHour ?? DEFAULT_PUSH_SETTINGS.reminderOneHour,
    reminderFifteenMin: raw.reminderFifteenMin ?? DEFAULT_PUSH_SETTINGS.reminderFifteenMin,
    dailySummary: raw.dailySummary ?? DEFAULT_PUSH_SETTINGS.dailySummary,
    dailySummaryTime: raw.dailySummaryTime ?? DEFAULT_PUSH_SETTINGS.dailySummaryTime,
    timezone: raw.timezone ?? DEFAULT_PUSH_SETTINGS.timezone,
  };
}
