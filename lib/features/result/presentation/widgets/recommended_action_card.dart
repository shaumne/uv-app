import 'package:flutter/material.dart';
import 'package:uv_dosimeter/l10n/app_localizations.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/uv_analysis_result.dart';

/// Card showing SPF status and recommended action.
///
/// All copy sourced from ARB files — no hardcoded strings.
/// Renders the AdMob banner at the bottom (no-op when [FeatureToggles.areAdsEnabled] = false).
class RecommendedActionCard extends StatelessWidget {
  const RecommendedActionCard({required this.result, super.key});

  final UvAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.subtleDivider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.result_recommendedAction_label, style: AppTypography.labelSmall),
              const SizedBox(height: 10),
              Text(_action(l10n), style: AppTypography.bodyLarge),
              if (result.sunscreenReapplyRecommended) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.goldenCaution,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.result_spfFaded,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.uvWarnAmber,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // SPF effective value
              Row(
                children: [
                  Text(l10n.result_spfCurrent, style: AppTypography.labelSmall),
                  Text(
                    result.spfEffectiveNow.toStringAsFixed(1),
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepInk,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // AdMob banner — zero size when ads are disabled
        AdService.bannerWidget(),
      ],
    );
  }

  String _action(AppLocalizations l10n) {
    if (result.isExceeded || result.isDanger) return l10n.result_action_shade;
    if (result.isWarning) return l10n.result_action_partial;
    if (result.sunscreenReapplyRecommended) return l10n.result_action_reapply;
    if (result.isCaution) return l10n.result_action_caution;
    return l10n.result_action_good;
  }
}
