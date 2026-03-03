import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/uv_analysis_result.dart';

/// Large header card showing primary Bihaku-toned result message.
///
/// Copy follows Cultural_Localization_Expert skill — encouraging, never alarming.
/// All strings sourced from ARB files, never hardcoded.
class ResultHeaderCard extends StatelessWidget {
  const ResultHeaderCard({required this.result, super.key});

  final UvAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.subtleDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sticker colour swatch
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _hexToColor(result.hexColor),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.subtleDivider, width: 1),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                result.hexColor,
                style: AppTypography.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Primary message (skill: Bihaku tone for ja, direct for en, warm for tr)
          Text(_primaryMessage(l10n), style: AppTypography.headlineMed),
        ],
      ),
    );
  }

  /// All messages delegate to ARB — fully localised, Bihaku-safe for Japanese.
  String _primaryMessage(AppLocalizations l10n) {
    if (result.isExceeded) return l10n.result_exceeded_full;
    if (result.isDanger) return l10n.result_danger_full;
    if (result.isWarning) {
      return l10n.result_warning_full(result.medUsedPercent.toStringAsFixed(0));
    }
    if (result.isCaution) {
      return l10n.result_caution_full(result.remainingMinutes);
    }
    return l10n.result_safe_full;
  }

  Color _hexToColor(String hex) {
    try {
      final h = hex.replaceFirst('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return AppColors.bihakuLavender;
    }
  }
}
