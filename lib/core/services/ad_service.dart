import 'package:flutter/widgets.dart';
import '../config/feature_toggles.dart';
import '../utils/logger.dart';

/// AdMob integration service.
///
/// Entire surface area is guarded by [FeatureToggles.areAdsEnabled].
/// [bannerWidget] returns [SizedBox.shrink] when ads are disabled —
/// no layout shifts or placeholder rectangles.
class AdService {
  AdService._();

  static const String _interstitialId = 'ca-app-pub-XXXX/YYYY'; // prod
  // Test ID: 'ca-app-pub-3940256099942544/1033173712'

  /// Initialises AdMob SDK. No-op when ads are disabled.
  static Future<void> init() async {
    if (!FeatureToggles.areAdsEnabled) return;
    // await MobileAds.instance.initialize();
    appLogger.i('[AdMob] Initialised (ads enabled).');
  }

  /// Loads an interstitial ad into memory. No-op when ads are disabled.
  static Future<void> loadInterstitial() async {
    if (!FeatureToggles.areAdsEnabled) return;
    // InterstitialAd.load(...)
  }

  /// Shows the preloaded interstitial. No-op when ads are disabled.
  static void showInterstitial() {
    if (!FeatureToggles.areAdsEnabled) return;
    // _interstitial?.show();
  }

  /// Returns a banner widget, or [SizedBox.shrink] when ads are disabled.
  static Widget bannerWidget() {
    if (!FeatureToggles.areAdsEnabled) return const SizedBox.shrink();
    // return _BannerAdWidget();
    return const SizedBox.shrink();
  }
}
