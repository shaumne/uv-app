import 'package:flutter/material.dart';
import 'package:uv_dosimeter/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/uv_analysis_result.dart';

/// Card displaying MED percentage used with dataDisplay typography.
/// All labels are sourced from ARB — fully localised.
class MedUsageCard extends StatelessWidget {
  const MedUsageCard({required this.result, super.key});

  final UvAnalysisResult result;

  Color get _accentColor {
    if (result.medUsedFraction < 0.5) return AppColors.uvSafeGreen;
    if (result.medUsedFraction < 0.8) return AppColors.uvWarnAmber;
    return AppColors.uvDangerCoral;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.subtleDivider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.result_medUsed_label, style: AppTypography.labelSmall),
                const SizedBox(height: 8),
                Text(
                  '${result.medUsedPercent.toStringAsFixed(0)}%',
                  style: AppTypography.dataDisplay.copyWith(color: _accentColor),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(l10n.result_uvReading_label, style: AppTypography.labelSmall),
              const SizedBox(height: 4),
              Text(
                '${result.uvPercent.toStringAsFixed(1)}%',
                style: AppTypography.bodyLarge.copyWith(color: _accentColor),
              ),
              const SizedBox(height: 4),
              Text(
                '${result.remainingMinutes} ${l10n.result_timeLeft_label}',
                style: AppTypography.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
