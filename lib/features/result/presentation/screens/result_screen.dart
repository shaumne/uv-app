import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uv_dosimeter/l10n/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/data/repositories/dose_history_repository_impl.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../onboarding/presentation/providers/skin_profile_provider.dart';
import '../../domain/entities/uv_analysis_result.dart';
import '../../domain/usecases/save_dose_record.dart';
import '../widgets/med_usage_card.dart';
import '../widgets/recommended_action_card.dart';
import '../widgets/result_header_card.dart';
import '../widgets/staggered_reveal_wrapper.dart';

/// Result screen — UV analysis outcome with staggered card reveal.
///
/// Background tint adapts to risk level per Premium_Cosmeceutical_UI_Designer:
///   safe/caution → sakuraMist
///   warning      → goldenCaution
///   danger/exceeded → coralRisk
///
/// Persists the scan result to local dose history on mount.
class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({required this.result, super.key});
  final UvAnalysisResult result;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  @override
  void initState() {
    super.initState();
    // Persist dose immediately after screen mounts
    _saveDose();
  }

  Future<void> _saveDose() async {
    // Show interstitial ad when feature is enabled (currently dormant)
    AdService.showInterstitial();
    final profileAsync = ref.read(storedSkinProfileProvider);
    final profile = profileAsync.maybeWhen(data: (p) => p, orElse: () => null);
    final fitzpatrickType = profile?.fitzpatrickType ?? 2;

    // Convert medUsedFraction back to J/m² using the correct MED baseline
    final medBase = {1: 200, 2: 250, 3: 350, 4: 500, 5: 700, 6: 1000};
    final baseline = (medBase[fitzpatrickType] ?? 250).toDouble();
    final cumulativeJm2 = widget.result.medUsedFraction * baseline;

    final repo = ref.read(doseHistoryRepositoryProvider);
    await SaveDoseRecord(repo)(
      cumulativeDoseJm2: cumulativeJm2,
      fitzpatrickType: fitzpatrickType,
    );
    ref.invalidate(homeNotifierProvider);
  }

  Color get _backgroundTint {
    if (widget.result.isSafe || widget.result.isCaution) {
      return AppColors.sakuraMist;
    }
    if (widget.result.isWarning) return AppColors.goldenCaution;
    return AppColors.coralRisk;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundTint,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(AppLocalizations.of(context)!.result_screen_title),
        leading: IconButton(
          icon: PhosphorIcon(PhosphorIconsRegular.caretLeft, size: 18),
          onPressed: () => context.go(RouteNames.home),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Card 0 — header
              StaggeredRevealWrapper(
                index: 0,
                child: ResultHeaderCard(result: widget.result),
              ),
              const SizedBox(height: 16),

              // Card 1 — MED usage + UV reading
              StaggeredRevealWrapper(
                index: 1,
                child: MedUsageCard(result: widget.result),
              ),
              const SizedBox(height: 16),

              // Card 2 — recommended action + ads placeholder
              StaggeredRevealWrapper(
                index: 2,
                child: RecommendedActionCard(result: widget.result),
              ),

              const SizedBox(height: 48),

              // CTA — scan again
              Builder(builder: (ctx) {
                final l10n = AppLocalizations.of(ctx)!;
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _ctaColor,
                        ),
                        onPressed: () => context.go(RouteNames.scan),
                        child: Text(l10n.scan_screen_title),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => context.go(RouteNames.home),
                        child: Text(
                          l10n.result_backHome,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.deepInk.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Color get _ctaColor {
    if (widget.result.requiresAction) return AppColors.uvDangerCoral;
    if (widget.result.isWarning) return AppColors.uvWarnAmber;
    return AppColors.bihakuLavender;
  }
}
