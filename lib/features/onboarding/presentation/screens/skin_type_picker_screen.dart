import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uv_dosimeter/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../app/router/route_names.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/fitzpatrick_card.dart';
import '../widgets/spf_slider_widget.dart';

/// Full onboarding flow: Fitzpatrick skin type selection + SPF choice.
///
/// Uses [OnboardingNotifier] for state. On completion, persists the
/// skin profile and navigates to [HomeScreen].
class SkinTypePickerScreen extends ConsumerWidget {
  const SkinTypePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    // Skin type data built from l10n keys.
    final types = [
      (type: 1, label: l10n.onboarding_fitzpatrickType1_label, desc: l10n.onboarding_fitzpatrickType1_desc),
      (type: 2, label: l10n.onboarding_fitzpatrickType2_label, desc: l10n.onboarding_fitzpatrickType2_desc),
      (type: 3, label: l10n.onboarding_fitzpatrickType3_label, desc: l10n.onboarding_fitzpatrickType3_desc),
      (type: 4, label: l10n.onboarding_fitzpatrickType4_label, desc: l10n.onboarding_fitzpatrickType4_desc),
      (type: 5, label: l10n.onboarding_fitzpatrickType5_label, desc: l10n.onboarding_fitzpatrickType5_desc),
      (type: 6, label: l10n.onboarding_fitzpatrickType6_label, desc: l10n.onboarding_fitzpatrickType6_desc),
    ];

    // Show error snackbar when save fails.
    ref.listen<OnboardingState>(onboardingNotifierProvider, (prev, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.uvDangerCoral,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.clinicalWhite,
      appBar: AppBar(
        title: Text(l10n.onboarding_welcome_title),
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: context.pop,
              )
            : null,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  Text(
                    l10n.onboarding_fitzpatrick_question,
                    style: AppTypography.headlineMed,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.onboarding_welcome_subtitle,
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Fitzpatrick cards
                  ...types.map((t) => FitzpatrickCard(
                        type: t.type,
                        label: t.label,
                        description: t.desc,
                        swatchColor: fitzpatrickSwatchColors[t.type]!,
                        isSelected: state.selectedType == t.type,
                        onTap: () => notifier.selectSkinType(t.type),
                      )),

                  const SizedBox(height: 32),

                  // Divider
                  const Divider(height: 1),
                  const SizedBox(height: 32),

                  // SPF slider
                  SpfSliderWidget(
                    selectedSpf: state.selectedSpf,
                    onChanged: notifier.selectSpf,
                  ),

                  const SizedBox(height: 48),

                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isSaving
                          ? null
                          : () async {
                              final success =
                                  await notifier.saveAndComplete();
                              if (success && context.mounted) {
                                context.go(RouteNames.home);
                              }
                            },
                      child: state.isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l10n.onboarding_start_button),
                    ),
                  ),
                  const SizedBox(height: 48),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
