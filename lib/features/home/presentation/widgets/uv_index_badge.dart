import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Compact UV index badge displayed in the top-right of the Home screen.
class UvIndexBadge extends StatelessWidget {
  const UvIndexBadge({required this.uvIndex, required this.riskCategory, super.key});

  final double uvIndex;
  final String riskCategory;

  @override
  Widget build(BuildContext context) {
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
              Text(riskCategory, style: AppTypography.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Color get _badgeColor {
    if (uvIndex < 3) return AppColors.uvSafeGreen;
    if (uvIndex < 6) return AppColors.uvWarnAmber;
    if (uvIndex < 8) return AppColors.uvWarnAmber;
    return AppColors.uvDangerCoral;
  }
}
