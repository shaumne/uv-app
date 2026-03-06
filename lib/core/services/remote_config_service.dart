import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../utils/logger.dart';

/// Firebase Remote Config reader.
///
/// Fetches `is_premium_mode_active` and `are_ads_enabled` boolean flags
/// from Firebase Remote Config, enabling instant activation of monetisation
/// features without an app update.
///
/// Fails gracefully — if Firebase is not yet initialised (google-services.json
/// not present) or the fetch times out, local default values (false) are used
/// and the app continues normally.
///
/// Setup requirements:
///   1. Add `google-services.json` (Android) to `android/app/`
///   2. Add `GoogleService-Info.plist` (iOS) to `ios/Runner/`
///   3. Ensure `Firebase.initializeApp()` is called in main.dart before this.
class RemoteConfigService {
  RemoteConfigService._();

  static bool _isPremiumModeActive = false;
  static bool _areAdsEnabled = false;

  /// Fetches Remote Config values and caches them locally.
  ///
  /// Safe to call when Firebase is uninitialised — catches all exceptions
  /// and falls back to safe defaults (all features off).
  static Future<void> init() async {
    try {
      final rc = FirebaseRemoteConfig.instance;

      await rc.setDefaults(const {
        'is_premium_mode_active': false,
        'are_ads_enabled': false,
      });

      await rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await rc.fetchAndActivate();

      _isPremiumModeActive = rc.getBool('is_premium_mode_active');
      _areAdsEnabled = rc.getBool('are_ads_enabled');

      appLogger.i(
        '[RemoteConfig] Fetched — premium: $_isPremiumModeActive, ads: $_areAdsEnabled',
      );
    } catch (e, st) {
      // Graceful degradation: Firebase not initialised or network unavailable.
      // App continues with local FeatureToggles defaults (all false).
      appLogger.w(
        '[RemoteConfig] init failed — using local defaults (all features off).',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Whether the premium mode flag is active in Remote Config.
  static bool get isPremiumModeActive => _isPremiumModeActive;

  /// Whether ads are enabled in Remote Config.
  static bool get areAdsEnabled => _areAdsEnabled;
}
