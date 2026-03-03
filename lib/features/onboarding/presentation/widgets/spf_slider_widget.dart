import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// SPF selection slider.
///
/// Snaps to common SPF values: 1, 15, 30, 50.
/// 1 = no sunscreen (bare skin).
class SpfSliderWidget extends StatelessWidget {
  const SpfSliderWidget({
    required this.selectedSpf,
    required this.onChanged,
    super.key,
  });

  final int selectedSpf;
  final ValueChanged<int> onChanged;

  static const _spfValues = [1, 15, 30, 50];

  @override
  Widget build(BuildContext context) {
    final idx = _spfValues.indexOf(selectedSpf).clamp(0, _spfValues.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SPF label + current value badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Sunscreen SPF', style: AppTypography.bodyLarge),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey(selectedSpf),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bihakuLavender.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  selectedSpf == 1 ? 'None' : 'SPF $selectedSpf',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.bihakuLavender,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Slider
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.bihakuLavender,
            inactiveTrackColor: AppColors.subtleDivider,
            thumbColor: AppColors.bihakuLavender,
            overlayColor: AppColors.bihakuLavender.withValues(alpha: 0.15),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            min: 0,
            max: (_spfValues.length - 1).toDouble(),
            divisions: _spfValues.length - 1,
            value: idx.toDouble(),
            onChanged: (v) => onChanged(_spfValues[v.round()]),
          ),
        ),
        // Tick labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _spfValues.map((v) {
              final isActive = v == selectedSpf;
              return Text(
                v == 1 ? 'None' : 'SPF $v',
                style: AppTypography.labelSmall.copyWith(
                  color: isActive
                      ? AppColors.bihakuLavender
                      : AppColors.deepInk.withValues(alpha: 0.35),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
