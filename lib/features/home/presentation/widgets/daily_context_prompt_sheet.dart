import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uv_dosimeter/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../onboarding/domain/entities/skin_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../onboarding/presentation/providers/skin_profile_provider.dart';

/// Bottom sheet shown on first app open of the day.
/// Asks for today's context and ground surface — values can change daily.
class DailyContextPromptSheet extends ConsumerStatefulWidget {
  const DailyContextPromptSheet({
    required this.currentProfile,
    required this.onSaved,
    super.key,
  });

  final SkinProfile currentProfile;
  final VoidCallback onSaved;

  @override
  ConsumerState<DailyContextPromptSheet> createState() =>
      _DailyContextPromptSheetState();
}

class _DailyContextPromptSheetState extends ConsumerState<DailyContextPromptSheet> {
  bool _isSaving = false;
  late String _dailyContext;
  late String _albedo;

  @override
  void initState() {
    super.initState();
    _dailyContext = widget.currentProfile.dailyContext;
    _albedo = widget.currentProfile.albedo;
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final profile = widget.currentProfile.copyWith(
      dailyContext: _dailyContext,
      albedo: _albedo,
    );
    final saveUseCase = ref.read(saveSkinProfileProvider);
    final result = await saveUseCase(profile);
    result.fold(
      (_) {
        if (mounted) setState(() => _isSaving = false);
      },
      (_) {
        ref.invalidate(storedSkinProfileProvider);
        widget.onSaved();
        if (mounted) Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.subtleDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.daily_prompt_title, style: AppTypography.headlineMed),
            const SizedBox(height: 8),
            Text(
              l10n.daily_prompt_subtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.deepInk.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              l10n.onboarding_dailyContext_label,
              style: AppTypography.labelSmall.copyWith(letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(
                  label: l10n.onboarding_dailyContext_city,
                  isSelected: _dailyContext == 'daily_city',
                  onTap: () => setState(() => _dailyContext = 'daily_city'),
                ),
                _Chip(
                  label: l10n.onboarding_dailyContext_beach,
                  isSelected: _dailyContext == 'beach_swimming',
                  onTap: () => setState(() => _dailyContext = 'beach_swimming'),
                ),
                _Chip(
                  label: l10n.onboarding_dailyContext_sport,
                  isSelected: _dailyContext == 'intense_sport',
                  onTap: () => setState(() => _dailyContext = 'intense_sport'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              l10n.onboarding_albedo_label,
              style: AppTypography.labelSmall.copyWith(letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(
                  label: l10n.onboarding_albedo_none,
                  isSelected: _albedo == 'none',
                  onTap: () => setState(() => _albedo = 'none'),
                ),
                _Chip(
                  label: l10n.onboarding_albedo_sand,
                  isSelected: _albedo == 'sand',
                  onTap: () => setState(() => _albedo = 'sand'),
                ),
                _Chip(
                  label: l10n.onboarding_albedo_snow,
                  isSelected: _albedo == 'snow',
                  onTap: () => setState(() => _albedo = 'snow'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.settings_save_button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.uvSafeGreen.withValues(alpha: 0.12)
              : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.uvSafeGreen : AppColors.subtleDivider,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected
                ? AppColors.uvSafeGreen
                : AppColors.deepInk.withValues(alpha: 0.6),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
