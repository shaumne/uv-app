import '../config/feature_toggles.dart';
import '../utils/logger.dart';

/// RevenueCat subscription management service.
///
/// All public methods are guarded by [FeatureToggles.isPremiumModeActive].
/// When the toggle is false every call returns immediately — zero SDK overhead.
///
/// To activate: set [FeatureToggles.isPremiumModeActive] = true and replace
/// the placeholder API keys with production values.
class RevenueCatService {
  RevenueCatService._();

  // Replace with real keys before enabling the toggle.
  static const String _iosApiKey = 'appl_REPLACE_WITH_PRODUCTION_KEY';
  static const String _androidApiKey = 'goog_REPLACE_WITH_PRODUCTION_KEY';

  /// Initialises the RevenueCat SDK.
  /// No-op when [FeatureToggles.isPremiumModeActive] is false.
  static Future<void> init() async {
    if (!FeatureToggles.isPremiumModeActive) return;

    // Uncomment after adding purchases_flutter and enabling the toggle:
    // await Purchases.configure(
    //   PurchasesConfiguration(_iosApiKey) // switch on platform
    //     ..appUserID = null, // RevenueCat generates anonymous ID
    // );
    appLogger.i('[RevenueCat] Initialised (premium mode active).');
  }

  /// Returns true if the user holds an active premium entitlement.
  static Future<bool> isPremium() async {
    if (!FeatureToggles.isPremiumModeActive) return false;
    // final info = await Purchases.getCustomerInfo();
    // return info.entitlements.active.containsKey('premium');
    return false;
  }
}
