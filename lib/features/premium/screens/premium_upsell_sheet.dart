import 'package:flutter/material.dart';
import 'package:uv_dosimeter/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Bottom sheet shown when a premium-gated feature is accessed
/// by a non-premium user.
///
/// Currently dormant — only displayed when
/// [FeatureToggles.isPremiumModeActive] = true.
/// All copy is in ARB files (en/ja/tr) for full localisation.
class PremiumUpsellSheet extends StatelessWidget {
  const PremiumUpsellSheet({super.key});

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
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.subtleDivider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),

          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.bihakuLavender, AppColors.uvSafeGreen],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.star_rounded, color: Colors.white, size: 32),
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

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // RevenueCatService.purchase() invoked here when monetisation is activated
                Navigator.of(context).pop();
              },
              child: Text(l10n.premium_upgrade_button),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
