import 'package:flutter/material.dart';
import 'package:uv_dosimeter/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Pill chip showing safe sun exposure time remaining.
///
/// Uses [AppLocalizations] for all displayed text — no hardcoded strings.
class RemainingTimeChip extends StatelessWidget {
  const RemainingTimeChip({
    required this.minutes,
    required this.medFraction,
    super.key,
  });

  final int minutes;
  final double medFraction;

  Color get _statusColor {
    if (medFraction < 0.5) return AppColors.uvSafeGreen;
    if (medFraction < 0.8) return AppColors.uvWarnAmber;
    return AppColors.uvDangerCoral;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = minutes <= 0
        ? l10n.home_daily_limit_reached
        : l10n.home_remaining_minutes(minutes);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _statusColor.withValues(alpha: 0.30)),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: _statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
