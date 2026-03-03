import '../utils/logger.dart';

/// Firebase Remote Config reader — from Monetization_Stealth_Controller skill.
///
/// Fetches `is_premium_mode_active` and `are_ads_enabled` flags from
/// Firebase Remote Config, allowing instant activation of monetisation
/// features without an app update.
///
/// Currently returns the local [FeatureToggles] defaults because
/// Firebase is not yet initialised (google-services.json not added).
/// To activate: uncomment the Firebase imports and init block below,
/// add google-services.json / GoogleService-Info.plist, and call
/// [RemoteConfigService.init()] in main.dart.
class RemoteConfigService {
  RemoteConfigService._();

  static bool _isPremiumModeActive = false;
  static bool _areAdsEnabled = false;

  /// Fetches Remote Config values and caches them.
  /// Safe to call with Firebase uninitialised — returns local defaults.
  static Future<void> init() async {
    try {
      // ── Uncomment when Firebase is added ─────────────────────────────────
      // final rc = FirebaseRemoteConfig.instance;
      // await rc.setDefaults({
      //   'is_premium_mode_active': false,
      //   'are_ads_enabled':        false,
      // });
      // await rc.setConfigSettings(RemoteConfigSettings(
      //   fetchTimeout:      const Duration(seconds: 10),
      //   minimumFetchInterval: const Duration(hours: 1),
      // ));
      // await rc.fetchAndActivate();
      // _isPremiumModeActive = rc.getBool('is_premium_mode_active');
      // _areAdsEnabled       = rc.getBool('are_ads_enabled');
      appLogger.i('[RemoteConfig] Loaded defaults (Firebase not yet initialised).');
    } catch (e, st) {
      appLogger.e('[RemoteConfig] init failed — using local defaults', error: e, stackTrace: st);
    }
  }

  static bool get isPremiumModeActive => _isPremiumModeActive;
  static bool get areAdsEnabled => _areAdsEnabled;
}
