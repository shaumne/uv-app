import 'package:flutter/material.dart';
import '../../core/config/feature_toggles.dart';
import '../../core/services/revenue_cat_service.dart';
import 'screens/premium_upsell_sheet.dart';

/// Widget-level paywall gate — from Monetization_Stealth_Controller skill.
///
/// When [FeatureToggles.isPremiumModeActive] is false (current default),
/// [child] is rendered freely — zero overhead.
///
/// When the toggle is flipped to true, wraps [child] in a RevenueCat
/// entitlement check. Non-premium users see [lockedFallback] or
/// [PremiumUpsellSheet] by default.
class PaywallGuard extends StatelessWidget {
  const PaywallGuard({
    required this.child,
    this.lockedFallback,
    super.key,
  });

  final Widget child;
  final Widget? lockedFallback;

  @override
  Widget build(BuildContext context) {
    // Feature off → render child freely, no API call
    if (!FeatureToggles.isPremiumModeActive) return child;

    return FutureBuilder<bool>(
      future: RevenueCatService.isPremium(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        if (snapshot.data == true) return child;
        return lockedFallback ?? const PremiumUpsellSheet();
      },
    );
  }
}
