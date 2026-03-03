/// Master feature switches for monetization and premium gating.
///
/// All flags default to [false] for the initial production release.
/// Activate via Firebase Remote Config (see [RemoteConfigService]) or
/// by flipping these constants during a controlled rollout.
class FeatureToggles {
  FeatureToggles._();

  // ── Master switches ──────────────────────────────────────────────────────
  static const bool isPremiumModeActive = false;
  static const bool areAdsEnabled = false;

  // ── Granular premium features (derived from master switch) ───────────────
  static const bool isPremiumSkinAnalysis = isPremiumModeActive;
  static const bool isSpotHistoryEnabled = isPremiumModeActive;
  static const bool isAdvancedUvReport = isPremiumModeActive;
}
