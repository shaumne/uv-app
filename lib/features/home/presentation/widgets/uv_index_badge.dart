import 'package:flutter/material.dart';
import 'package:uv_dosimeter/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/uv_index.dart';

/// Compact UV index badge displayed in the top-right of the Home screen.
///
/// Accepts a [UvRiskLevel] enum value and resolves the localised risk label
/// using [AppLocalizations] — never displays hardcoded English strings.
class UvIndexBadge extends StatelessWidget {
  const UvIndexBadge({
    required this.uvIndex,
    required this.riskLevel,
    super.key,
  });

  final double uvIndex;
  final UvRiskLevel riskLevel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final riskLabel = _riskLabel(l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _badgeColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: _badgeColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'UV ${uvIndex.toStringAsFixed(1)}',
                style: AppTypography.labelSmall.copyWith(
                  color: _badgeColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Text(riskLabel, style: AppTypography.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  String _riskLabel(AppLocalizations l10n) => switch (riskLevel) {
        UvRiskLevel.low      => l10n.home_uvRisk_low,
        UvRiskLevel.moderate => l10n.home_uvRisk_moderate,
        UvRiskLevel.high     => l10n.home_uvRisk_high,
        UvRiskLevel.veryHigh => l10n.home_uvRisk_veryHigh,
        UvRiskLevel.extreme  => l10n.home_uvRisk_extreme,
      };

  Color get _badgeColor => switch (riskLevel) {
        UvRiskLevel.low      => AppColors.uvSafeGreen,
        UvRiskLevel.moderate => AppColors.uvWarnAmber,
        UvRiskLevel.high     => AppColors.uvWarnAmber,
        UvRiskLevel.veryHigh => AppColors.uvDangerCoral,
        UvRiskLevel.extreme  => AppColors.uvDangerCoral,
      };
}
