import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/config/feature_toggles.dart';
import '../../../core/services/revenue_cat_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/logger.dart';
import '../../../l10n/app_localizations.dart';

/// Bottom sheet shown when a premium-gated feature is accessed.
///
/// Purchase flow:
/// - When [FeatureToggles.isPremiumModeActive] is false → tapping "Upgrade"
///   simply dismisses the sheet (dormant mode, no SDK calls).
/// - When [FeatureToggles.isPremiumModeActive] is true → fetches the current
///   RevenueCat offering and initiates a real purchase flow.
///
/// All copy is sourced from ARB files for full en/ja/tr localisation.
class PremiumUpsellSheet extends StatefulWidget {
  const PremiumUpsellSheet({super.key});

  @override
  State<PremiumUpsellSheet> createState() => _PremiumUpsellSheetState();
}

class _PremiumUpsellSheetState extends State<PremiumUpsellSheet> {
  bool _isPurchasing = false;

  Future<void> _onUpgradePressed() async {
    // When the monetisation toggle is inactive, dismiss without SDK call.
    if (!FeatureToggles.isPremiumModeActive) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    setState(() => _isPurchasing = true);
    try {
      final offerings = await RevenueCatService.getOfferings();
      final package = offerings?.current?.monthly;

      if (package == null) {
        appLogger.w('[PremiumUpsell] No current offering / monthly package found.');
        if (mounted) Navigator.of(context).pop();
        return;
      }

      await RevenueCatService.purchase(package);
    } on PurchasesErrorCode catch (e) {
      // User-cancelled purchase (code 1) is expected — log at debug level.
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        appLogger.d('[PremiumUpsell] User cancelled purchase.');
      } else {
        appLogger.e('[PremiumUpsell] Purchase error: $e');
      }
    } catch (e, st) {
      appLogger.e('[PremiumUpsell] Unexpected purchase error', error: e, stackTrace: st);
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.subtleDivider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),

          // Premium icon badge
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.bihakuLavender, AppColors.uvSafeGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: PhosphorIcon(PhosphorIconsFill.star, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 20),

          Text(l10n.premium_title, style: AppTypography.headlineMed),
          const SizedBox(height: 12),
          Text(
            l10n.premium_body,
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Upgrade CTA — real purchase when toggle is on, dismiss when off
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isPurchasing ? null : _onUpgradePressed,
              child: _isPurchasing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.premium_upgrade_button),
            ),
          ),
          const SizedBox(height: 12),

          TextButton(
            onPressed: _isPurchasing ? null : () => Navigator.of(context).pop(),
            child: Text(
              l10n.premium_later_button,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.deepInk.withValues(alpha: 0.45),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
