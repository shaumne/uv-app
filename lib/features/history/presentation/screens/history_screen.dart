import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uv_dosimeter/l10n/app_localizations.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/widgets/shimmer_loading.dart';
import '../../../premium/paywall_guard.dart';
import '../providers/history_provider.dart';

/// 7-day UV dose history screen.
///
/// Design: Premium_Cosmeceutical_UI_Designer — clinicalWhite bg, card-based
/// bar chart using CustomPainter, staggered entry animations.
/// Premium-gated via [PaywallGuard] / [FeatureToggles.isSpotHistoryEnabled].
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _reveal;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _reveal = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.clinicalWhite,
      appBar: AppBar(
        backgroundColor: AppColors.clinicalWhite,
        elevation: 0,
        title: Text(l10n.history_screen_title, style: AppTypography.headlineMed),
        leading: IconButton(
          icon: PhosphorIcon(PhosphorIconsRegular.caretLeft, size: 18),
          onPressed: () => context.go(RouteNames.home),
        ),
      ),
      body: SafeArea(
        child: PaywallGuard(
          lockedFallback: _LockedState(l10n: l10n),
          child: _HistoryBody(reveal: _reveal, l10n: l10n),
        ),
      ),
    );
  }
}

// ── Body (unlocked) ───────────────────────────────────────────────────────────

class _HistoryBody extends ConsumerWidget {
  const _HistoryBody({required this.reveal, required this.l10n});

  final Animation<double> reveal;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(weeklyDoseHistoryProvider);

    return asyncData.when(
      loading: () => const _LoadingState(),
      error: (e, _) => _EmptyState(l10n: l10n),
      data: (entries) {
        final hasData = entries.any((e) => e.doseJm2 > 0);
        if (!hasData) return _EmptyState(l10n: l10n);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.history_7days_label.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(letterSpacing: 1.6),
              ),
              const SizedBox(height: 20),

              // Bar chart card
              FadeTransition(
                opacity: reveal,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.subtleDivider),
                  ),
                  child: _WeekBarChart(entries: entries, l10n: l10n),
                ),
              ),

              const SizedBox(height: 24),

              // Per-day detail rows
              ...entries.asMap().entries.map((mapEntry) {
                final index = mapEntry.key;
                final day = mapEntry.value;
                if (day.doseJm2 == 0) return const SizedBox.shrink();
                return AnimatedBuilder(
                  animation: reveal,
                  builder: (_, child) {
                    final interval = CurvedAnimation(
                      parent: reveal,
                      curve: Interval(
                        (index * 0.1).clamp(0.0, 0.7),
                        ((index * 0.1) + 0.4).clamp(0.0, 1.0),
                        curve: Curves.easeOutCubic,
                      ),
                    );
                    return FadeTransition(
                      opacity: interval,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.12),
                          end: Offset.zero,
                        ).animate(interval),
                        child: child,
                      ),
                    );
                  },
                  child: _DayDetailRow(entry: day, l10n: l10n),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// ── Week Bar Chart ────────────────────────────────────────────────────────────

class _WeekBarChart extends StatelessWidget {
  const _WeekBarChart({required this.entries, required this.l10n});

  final List<DayDoseEntry> entries;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final maxFraction =
        entries.fold<double>(0, (m, e) => math.max(m, e.medFraction));
    final chartMax = math.max(maxFraction, 1.0);

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: entries.map((entry) {
              final barHeight =
                  entry.medFraction > 0 ? (entry.medFraction / chartMax) : 0.0;
              final barColor = _barColor(entry.medFraction);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // MED% label on tall bars
                      if (entry.medFraction > 0.1)
                        Text(
                          '${(entry.medFraction * 100).round()}%',
                          style: AppTypography.labelSmall.copyWith(
                            color: barColor,
                            fontSize: 9,
                            letterSpacing: 0,
                          ),
                        ),
                      const SizedBox(height: 4),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: barHeight),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (_, h, __) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 120 * h,
                          decoration: BoxDecoration(
                            color: entry.isToday
                                ? barColor
                                : barColor.withValues(alpha: 0.55),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                            border: entry.isToday
                                ? Border.all(color: barColor, width: 1.5)
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, color: AppColors.subtleDivider),
        const SizedBox(height: 8),
        // Day labels
        Row(
          children: entries.map((entry) {
            final dayLabel = DateFormat.E(locale).format(entry.date).substring(0, 2);
            return Expanded(
              child: Text(
                dayLabel,
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall.copyWith(
                  color: entry.isToday
                      ? AppColors.deepInk
                      : AppColors.deepInk.withValues(alpha: 0.45),
                  fontWeight:
                      entry.isToday ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 10,
                  letterSpacing: 0,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _barColor(double fraction) {
    if (fraction >= 1.0) return AppColors.uvDangerCoral;
    if (fraction >= 0.65) return AppColors.uvWarnAmber;
    return AppColors.uvSafeGreen;
  }
}

// ── Day Detail Row ────────────────────────────────────────────────────────────

class _DayDetailRow extends StatelessWidget {
  const _DayDetailRow({required this.entry, required this.l10n});

  final DayDoseEntry entry;
  final AppLocalizations l10n;

  String get _badgeLabel {
    if (entry.medFraction >= 1.0) return l10n.history_danger_badge;
    if (entry.medFraction >= 0.65) return l10n.history_warning_badge;
    if (entry.medFraction >= 0.40) return l10n.history_caution_badge;
    return l10n.history_safe_badge;
  }

  Color get _badgeColor {
    if (entry.medFraction >= 1.0) return AppColors.uvDangerCoral;
    if (entry.medFraction >= 0.65) return AppColors.uvWarnAmber;
    if (entry.medFraction >= 0.40) return AppColors.goldenCaution;
    return AppColors.uvSafeGreen;
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = entry.isToday
        ? 'Today'
        : DateFormat.MMMd(locale).format(entry.date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.subtleDivider),
        ),
        child: Row(
          children: [
            Text(dateLabel, style: AppTypography.bodyMedium),
            const Spacer(),
            Text(
              '${(entry.medFraction * 100).round()}%',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: _badgeColor,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _badgeColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                _badgeLabel,
                style: AppTypography.labelSmall.copyWith(
                  color: _badgeColor,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty / Loading States ────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const ShimmerBox(width: double.infinity, height: 180, radius: 20),
          const SizedBox(height: 16),
          const ShimmerBox(width: double.infinity, height: 64, radius: 16),
          const SizedBox(height: 8),
          const ShimmerBox(width: double.infinity, height: 64, radius: 16),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              PhosphorIconsRegular.sun,
              size: 56,
              color: AppColors.deepInk.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.history_noData_hint,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.deepInk.withValues(alpha: 0.45),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Paywall locked state ──────────────────────────────────────────────────────

class _LockedState extends StatelessWidget {
  const _LockedState({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.bihakuLavender, AppColors.uvSafeGreen],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: PhosphorIcon(PhosphorIconsRegular.lockOpen,
                  color: Colors.white, size: 32),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.history_premium_locked,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.deepInk.withValues(alpha: 0.55),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push(RouteNames.premiumUpsell),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bihakuLavender,
              ),
              child: Text(l10n.premium_upgrade_button),
            ),
          ],
        ),
      ),
    );
  }
}
