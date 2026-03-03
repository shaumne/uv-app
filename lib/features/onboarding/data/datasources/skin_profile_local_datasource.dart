import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/skin_profile_model.dart';

/// Persists and retrieves [SkinProfileModel] from SharedPreferences.
abstract interface class SkinProfileLocalDatasource {
  Future<void> save(SkinProfileModel model);
  Future<SkinProfileModel> load();
  Future<bool> isOnboardingComplete();
}

class SkinProfileLocalDatasourceImpl implements SkinProfileLocalDatasource {
  const SkinProfileLocalDatasourceImpl(this._prefs);
  final SharedPreferences _prefs;

  static const _keyProfile = 'skin_profile';
  static const _keyOnboarded = 'onboarding_complete';

  @override
  Future<void> save(SkinProfileModel model) async {
    try {
      await _prefs.setString(_keyProfile, jsonEncode(model.toJson()));
      await _prefs.setBool(_keyOnboarded, true);
    } catch (e) {
      throw CacheException(message: 'Failed to save skin profile: $e');
    }
  }

  @override
  Future<SkinProfileModel> load() async {
    try {
      final raw = _prefs.getString(_keyProfile);
      if (raw == null) {
        throw const CacheException(message: 'No skin profile stored.');
      }
      return SkinProfileModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Failed to load skin profile: $e');
    }
  }

  @override
  Future<bool> isOnboardingComplete() async =>
      _prefs.getBool(_keyOnboarded) ?? false;
}
