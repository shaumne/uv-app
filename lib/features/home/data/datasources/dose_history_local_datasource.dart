import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/constants/uv_constants.dart';

abstract interface class DoseHistoryLocalDatasource {
  /// Returns cumulative dose in J/m² for today.
  Future<double> getTodayCumulativeDoseJm2();

  /// Persists updated cumulative dose for today.
  Future<void> saveCumulativeDoseJm2(double doseJm2);

  /// Returns a map of date strings (yyyy-MM-dd) → cumulative dose J/m²
  /// for the past [days] calendar days (inclusive of today).
  Future<Map<String, double>> getHistoryForDays(int days);
}

/// Stores daily dose as JSON keyed by calendar date (yyyy-MM-dd).
/// Automatically resets when the date changes.
class DoseHistoryLocalDatasourceImpl implements DoseHistoryLocalDatasource {
  const DoseHistoryLocalDatasourceImpl(this._prefs);
  final SharedPreferences _prefs;

  static const _keyDoseHistory = 'dose_history';

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<double> getTodayCumulativeDoseJm2() async {
    try {
      final raw = _prefs.getString(_keyDoseHistory);
      if (raw == null) return 0.0;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return (map[_todayKey] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw CacheException(message: 'Failed to read dose history: $e');
    }
  }

  @override
  Future<void> saveCumulativeDoseJm2(double doseJm2) async {
    try {
      final raw = _prefs.getString(_keyDoseHistory);
      final map = raw != null
          ? jsonDecode(raw) as Map<String, dynamic>
          : <String, dynamic>{};
      map[_todayKey] = doseJm2;
      await _prefs.setString(_keyDoseHistory, jsonEncode(map));
    } catch (e) {
      throw CacheException(message: 'Failed to save dose history: $e');
    }
  }

  @override
  Future<Map<String, double>> getHistoryForDays(int days) async {
    try {
      final raw = _prefs.getString(_keyDoseHistory);
      final stored = raw != null
          ? jsonDecode(raw) as Map<String, dynamic>
          : <String, dynamic>{};

      final result = <String, double>{};
      final now = DateTime.now();
      for (int i = days - 1; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final key =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        result[key] = (stored[key] as num?)?.toDouble() ?? 0.0;
      }
      return result;
    } catch (e) {
      throw CacheException(message: 'Failed to read dose history: $e');
    }
  }
}
