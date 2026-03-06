import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/feature_toggles.dart';
import '../utils/logger.dart';

/// RevenueCat subscription management service.
///
/// All public methods are guarded by [FeatureToggles.isPremiumModeActive].
/// When the toggle is false every call returns immediately with zero SDK
/// overhead — the SDK is never initialised and no network calls are made.
///
/// When [FeatureToggles.isPremiumModeActive] is set to true (or driven by
/// Firebase Remote Config), the full SDK activates without any code change.
///
/// To activate:
///   1. Replace placeholder API keys below with real RevenueCat keys.
///   2. Set [FeatureToggles.isPremiumModeActive] = true (or via RC).
class RevenueCatService {
  RevenueCatService._();

  /// Replace with production keys from the RevenueCat dashboard.
  static const String _iosApiKey = 'appl_REPLACE_WITH_PRODUCTION_KEY';
  static const String _androidApiKey = 'goog_REPLACE_WITH_PRODUCTION_KEY';

  /// Initialises the RevenueCat SDK.
  ///
  /// Selects the correct API key for the current platform automatically.
  /// No-op when [FeatureToggles.isPremiumModeActive] is false.
  static Future<void> init() async {
    if (!FeatureToggles.isPremiumModeActive) return;

    final apiKey = defaultTargetPlatform == TargetPlatform.iOS
        ? _iosApiKey
        : _androidApiKey;

    await Purchases.configure(
      PurchasesConfiguration(apiKey)..appUserID = null,
    );
    appLogger.i('[RevenueCat] SDK initialised (platform: $defaultTargetPlatform).');
  }

  /// Returns true if the authenticated user holds an active 'premium'
  /// entitlement in RevenueCat.
  ///
  /// Always returns false when [FeatureToggles.isPremiumModeActive] is false.
  static Future<bool> isPremium() async {
    if (!FeatureToggles.isPremiumModeActive) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey('premium');
    } catch (e, st) {
      appLogger.e('[RevenueCat] isPremium check failed', error: e, stackTrace: st);
      return false;
    }
  }

  /// Initiates purchase flow for the given [Package].
  ///
  /// Throws [PurchasesErrorCode] on cancellation or failure — callers should
  /// catch and handle appropriately.
  /// No-op when [FeatureToggles.isPremiumModeActive] is false.
  static Future<void> purchase(Package package) async {
    if (!FeatureToggles.isPremiumModeActive) return;
    await Purchases.purchasePackage(package);
    appLogger.i('[RevenueCat] Purchase completed for: ${package.identifier}');
  }

  /// Fetches available offerings from RevenueCat.
  ///
  /// Returns null when [FeatureToggles.isPremiumModeActive] is false or on error.
  static Future<Offerings?> getOfferings() async {
    if (!FeatureToggles.isPremiumModeActive) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e, st) {
      appLogger.e('[RevenueCat] getOfferings failed', error: e, stackTrace: st);
      return null;
    }
  }
}
