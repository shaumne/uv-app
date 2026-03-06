import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Selectable card representing one Fitzpatrick skin type.
///
/// Design: AppColors.cardSurface base, bihakuLavender border + tint
/// when selected. Skin tone swatch circle on the left.
class FitzpatrickCard extends StatelessWidget {
  const FitzpatrickCard({
    required this.type,
    required this.label,
    required this.description,
    required this.swatchColor,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final int type;
  final String label;
  final String description;
  final Color swatchColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.bihakuLavender.withValues(alpha: 0.08)
            : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.bihakuLavender
              : AppColors.subtleDivider,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Skin tone swatch
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: swatchColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.subtleDivider,
                    width: 1,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Label + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.bodyLarge),
                    const SizedBox(height: 2),
                    Text(description, style: AppTypography.labelSmall),
                  ],
                ),
              ),
              // Selection indicator
              AnimatedOpacity(
                opacity: isSelected ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.bihakuLavender,
                    shape: BoxShape.circle,
                  ),
                  child: PhosphorIcon(PhosphorIconsBold.check, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Calibrated skin tone swatch colours for each Fitzpatrick type.
const fitzpatrickSwatchColors = {
  1: Color(0xFFF5E6D8),
  2: Color(0xFFEDD5B3),
  3: Color(0xFFD4A574),
  4: Color(0xFFB8835A),
  5: Color(0xFF8B5E3C),
  6: Color(0xFF4A2C17),
};
