import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/data/datasources/dose_history_local_datasource.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

/// A single day's UV dose summary for the history screen.
class DayDoseEntry {
  const DayDoseEntry({
    required this.dateKey,
    required this.date,
    required this.doseJm2,
    required this.medFraction,
  });

  /// Date formatted as yyyy-MM-dd.
  final String dateKey;
  final DateTime date;

  /// Cumulative UV dose in J/m² for this day.
  final double doseJm2;

  /// Fraction of the user's MED consumed (0.0 – 1.0+).
  final double medFraction;

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

// ── MED Lookup ────────────────────────────────────────────────────────────────

const _medTable = {1: 200.0, 2: 250.0, 3: 350.0, 4: 500.0, 5: 700.0, 6: 1000.0};

double _resolveMedBaseline(String? profileJson) {
  if (profileJson == null) return 250.0;
  try {
    final map = jsonDecode(profileJson) as Map<String, dynamic>;
    final type = (map['fitzpatrick_type'] as int?) ?? 2;
    return _medTable[type.clamp(1, 6)] ?? 250.0;
  } catch (_) {
    return 250.0;
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

/// Returns the last 7 days of UV dose data as an ordered list (oldest → newest).
///
/// Converts raw J/m² into MED fractions using the user's Fitzpatrick type
/// from SharedPreferences — matches the Dermatology_Math_Engine skill pipeline.
final weeklyDoseHistoryProvider =
    FutureProvider.autoDispose<List<DayDoseEntry>>((ref) async {
  final datasource = ref.watch(doseHistoryLocalDatasourceProvider);
  final prefs = ref.read(sharedPreferencesProvider);

  final medBaseline = _resolveMedBaseline(prefs.getString('skin_profile'));
  final history = await datasource.getHistoryForDays(7);
  final now = DateTime.now();

  return List.generate(7, (i) {
    final date = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: 6 - i));
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final dose = history[key] ?? 0.0;
    return DayDoseEntry(
      dateKey: key,
      date: date,
      doseJm2: dose,
      medFraction: medBaseline > 0 ? (dose / medBaseline).clamp(0.0, 2.0) : 0.0,
    );
  });
});
