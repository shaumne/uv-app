import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/feature_toggles.dart';
import '../utils/logger.dart';

/// AdMob integration service.
///
/// Entire surface area is guarded by [FeatureToggles.areAdsEnabled].
/// [bannerWidget] returns [SizedBox.shrink] when ads are disabled —
/// no layout shifts or placeholder rectangles in the UI.
///
/// When [FeatureToggles.areAdsEnabled] is set to true (or driven via
/// Firebase Remote Config), the full AdMob SDK activates without any
/// code change required.
///
/// To activate:
///   1. Replace placeholder ad unit IDs with real AdMob IDs.
///   2. Set [FeatureToggles.areAdsEnabled] = true (or via RC).
class AdService {
  AdService._();

  static InterstitialAd? _interstitial;

  /// Production interstitial ad unit ID.
  /// Test ID: 'ca-app-pub-3940256099942544/1033173712'
  static const String _interstitialId = 'ca-app-pub-XXXX/YYYY';

  /// Production banner ad unit ID.
  /// Test ID: 'ca-app-pub-3940256099942544/6300978111'
  static const String _bannerId = 'ca-app-pub-XXXX/ZZZZ';

  /// Initialises the AdMob SDK. No-op when ads are disabled.
  static Future<void> init() async {
    if (!FeatureToggles.areAdsEnabled) return;
    await MobileAds.instance.initialize();
    appLogger.i('[AdMob] SDK initialised.');
  }

  /// Preloads an interstitial ad into memory. No-op when ads are disabled.
  ///
  /// Call this on result screen entry so the ad is ready when [showInterstitial]
  /// is invoked. Safe to call multiple times — existing ad is replaced.
  static Future<void> loadInterstitial() async {
    if (!FeatureToggles.areAdsEnabled) return;
    await InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          appLogger.d('[AdMob] Interstitial loaded.');
        },
        onAdFailedToLoad: (err) {
          appLogger.w('[AdMob] Interstitial load failed: ${err.message}');
          _interstitial = null;
        },
      ),
    );
  }

  /// Displays the preloaded interstitial. No-op when ads are disabled or
  /// no ad has been loaded yet.
  static void showInterstitial() {
    if (!FeatureToggles.areAdsEnabled) return;
    _interstitial?.show();
    _interstitial = null;
  }

  /// Returns a live banner widget, or [SizedBox.shrink] when ads are disabled.
  ///
  /// The returned widget manages its own [BannerAd] lifecycle (load, dispose).
  static Widget bannerWidget() {
    if (!FeatureToggles.areAdsEnabled) return const SizedBox.shrink();
    return _BannerAdWidget(adUnitId: _bannerId);
  }
}

/// Self-contained banner ad widget that manages [BannerAd] lifecycle.
///
/// Creates, loads, and disposes the ad automatically via [State] lifecycle.
class _BannerAdWidget extends StatefulWidget {
  const _BannerAdWidget({required this.adUnitId});
  final String adUnitId;

  @override
  State<_BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<_BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final ad = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
          appLogger.d('[AdMob] Banner loaded.');
        },
        onAdFailedToLoad: (ad, err) {
          appLogger.w('[AdMob] Banner load failed: ${err.message}');
          ad.dispose();
        },
      ),
    );
    _bannerAd = ad;
    ad.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
