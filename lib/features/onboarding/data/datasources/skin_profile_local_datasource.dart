import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/error/exceptions.dart';
import '../models/skin_profile_model.dart';

/// Persists and retrieves [SkinProfileModel] from secure storage (Keychain/Keystore).
///
/// Skin profile and onboarding status are personal health data — stored
/// encrypted via [FlutterSecureStorage] for GDPR/KVKK compliance.
abstract interface class SkinProfileLocalDatasource {
  Future<void> save(SkinProfileModel model);
  Future<SkinProfileModel> load();
  Future<bool> isOnboardingComplete();
  Future<void> clear();
}

class SkinProfileLocalDatasourceImpl implements SkinProfileLocalDatasource {
  const SkinProfileLocalDatasourceImpl(this._storage);
  final FlutterSecureStorage _storage;

  static const _keyProfile = 'skin_profile';
  static const _keyOnboarded = 'onboarding_complete';

  @override
  Future<void> save(SkinProfileModel model) async {
    try {
      await _storage.write(key: _keyProfile, value: jsonEncode(model.toJson()));
      await _storage.write(key: _keyOnboarded, value: 'true');
    } catch (e) {
      throw CacheException(message: 'Failed to save skin profile: $e');
    }
  }

  @override
  Future<SkinProfileModel> load() async {
    try {
      final raw = await _storage.read(key: _keyProfile);
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
  Future<bool> isOnboardingComplete() async {
    final value = await _storage.read(key: _keyOnboarded);
    return value == 'true';
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _keyProfile);
      await _storage.delete(key: _keyOnboarded);
    } catch (e) {
      throw CacheException(message: 'Failed to clear skin profile: $e');
    }
  }
}
