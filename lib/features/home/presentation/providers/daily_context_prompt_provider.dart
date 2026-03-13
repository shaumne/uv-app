import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../onboarding/presentation/providers/onboarding_provider.dart';

const _keyLastPromptDate = 'daily_context_last_prompt_date';

/// Returns true if we should show the daily context prompt (first open of the day).
Future<bool> shouldShowDailyContextPrompt(SharedPreferences prefs) async {
  final today = _todayKey();
  final last = prefs.getString(_keyLastPromptDate);
  return last != today;
}

/// Marks that we've shown/saved the daily context prompt for today.
Future<void> markDailyContextPromptShown(SharedPreferences prefs) async {
  await prefs.setString(_keyLastPromptDate, _todayKey());
}

String _todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}
