import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  // Skin type metadata — labels from Cultural_Localization_Expert skill
  static const _types = [
    (type: 1, label: 'Type I — Very Fair', desc: 'Always burns, never tans'),
    (type: 2, label: 'Type II — Fair', desc: 'Usually burns, sometimes tans'),
    (type: 3, label: 'Type III — Medium', desc: 'Sometimes burns, always tans'),
    (type: 4, label: 'Type IV — Olive', desc: 'Rarely burns, always tans'),
    (type: 5, label: 'Type V — Brown', desc: 'Very rarely burns'),
    (type: 6, label: 'Type VI — Deep', desc: 'Never burns'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    // Show error snackbar when save fails
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
        title: const Text('Your Skin Profile'),
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
                    'Which skin tone best describes you?',
                    style: AppTypography.headlineMed,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This helps us calculate your personal UV limit.',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Fitzpatrick cards
                  ..._types.map((t) => FitzpatrickCard(
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
                          : const Text('Start Protecting My Skin'),
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
