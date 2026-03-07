import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uv_dosimeter/l10n/app_localizations.dart';
import '../../../../app/di/providers.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/home_provider.dart';
import '../widgets/remaining_time_chip.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/uv_arc_gauge.dart';
import '../widgets/uv_index_badge.dart';

/// Called when the user taps "Scan My Sticker". Requests camera permission
/// first; only navigates to scan screen if granted. On denial, shows a
/// localised dialog with Open Settings and Retry.
Future<void> _onScanPressed(BuildContext context, WidgetRef ref) async {
  final permissionService = ref.read(permissionServiceProvider);
  final l10n = AppLocalizations.of(context)!;
  final result = await permissionService.requestCamera();
  if (!context.mounted) return;
  result.fold(
    (failure) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(l10n.error_camera),
          actions: [
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(ctx).pop();
              },
              child: Text(l10n.error_settings_button),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.error_retry_button),
            ),
          ],
        ),
      );
    },
    (_) => context.go(RouteNames.scan),
  );
}

/// Maps location error code from [LocationFailure.message] to l10n string.
String _locationErrorMessage(String code, AppLocalizations l10n) {
  switch (code) {
    case 'location_services_off':
      return l10n.error_location_services_off;
    case 'location_denied_forever':
      return l10n.error_location_denied_forever;
    case 'location_denied':
      return l10n.error_location_denied;
    case 'location_timeout':
      return l10n.error_location_timeout;
    case 'location_unavailable':
      return l10n.error_location_unavailable;
    default:
      return l10n.error_location_unavailable;
  }
}

/// Home screen — main dashboard.
///
/// Layout follows Premium_Cosmeceutical_UI_Designer skill:
/// - clinicalWhite background
/// - UV index badge top-right
/// - UvArcGauge centre (160→200dp, TweenAnimationBuilder animated)
/// - RemainingTimeChip below gauge
/// - Single CTA scan button at bottom
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeNotifierProvider);
    final notifier = ref.read(homeNotifierProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    // Show dose notifications with l10n when notifier sets pendingDoseNotification.
    ref.listen<HomeState>(homeNotifierProvider, (prev, next) {
      final pending = next.pendingDoseNotification;
      if (pending == null || !context.mounted) return;
      switch (pending) {
        case PendingDoseNotification.threshold80:
          NotificationService.showThreshold80(
            title: l10n.appName,
            body: l10n.notification_threshold80_body,
          );
          break;
        case PendingDoseNotification.dailyDone:
          NotificationService.showDailyDone(
            title: l10n.appName,
            body: l10n.notification_dailyDone_body,
          );
          break;
      }
      ref.read(homeNotifierProvider.notifier).clearPendingDoseNotification();
    });

    return Scaffold(
      backgroundColor: AppColors.clinicalWhite,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.bihakuLavender,
          onRefresh: notifier.loadAll,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 24),

                    // ── Header row ────────────────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.home_title,
                                  style: AppTypography.headlineMed),
                              Text(
                                _dateLabel(context),
                                style: AppTypography.labelSmall,
                              ),
                            ],
                          ),
                        ),

                        // UV index badge
                        if (state.isLoadingUv)
                          const ShimmerBox(width: 80, height: 40, radius: 20)
                        else if (state.uvIndex != null)
                          UvIndexBadge(
                            uvIndex: state.uvIndex!.value,
                            riskLevel: state.uvIndex!.riskLevel,
                          )
                        else if (state.uvFailure != null)
                          _ErrorBadge(
                            message: state.uvFailure! is LocationFailure
                                ? _locationErrorMessage(
                                    state.uvFailure!.message,
                                    l10n,
                                  )
                                : l10n.home_uvUnavailable,
                          ),

                        const SizedBox(width: 8),

                        // History button
                        GestureDetector(
                          onTap: () => context.go(RouteNames.history),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.subtleDivider,
                                width: 1,
                              ),
                            ),
                            child: PhosphorIcon(
                              PhosphorIconsRegular.chartBar,
                              size: 20,
                              color: AppColors.deepInk,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Settings button
                        GestureDetector(
                          onTap: () => context.go(RouteNames.settings),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.subtleDivider,
                                width: 1,
                              ),
                            ),
                            child: PhosphorIcon(
                              PhosphorIconsRegular.sliders,
                              size: 20,
                              color: AppColors.deepInk,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // ── Arc gauge ─────────────────────────────────────────────
                    Center(
                      child: state.isLoadingDose
                          ? const ShimmerBox(width: 200, height: 200, radius: 100)
                          : UvArcGauge(
                              percentage: state.doseSummary?.medUsedFraction ?? 0,
                            ),
                    ),

                    const SizedBox(height: 28),

                    // ── Remaining time chip ───────────────────────────────────
                    Center(
                      child: state.isLoadingDose
                          ? const ShimmerBox(width: 160, height: 36, radius: 24)
                          : RemainingTimeChip(
                              minutes:
                                  state.doseSummary?.remainingMinutes ?? 0,
                              medFraction:
                                  state.doseSummary?.medUsedFraction ?? 0,
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Status message
                    Center(
                      child: Text(
                        state.doseSummary == null
                            ? l10n.home_noData_hint2
                            : _statusMessage(l10n, state.doseSummary!.medUsedFraction),
                        style: AppTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // AdMob banner (no-op when FeatureToggles.areAdsEnabled = false)
                    AdService.bannerWidget(),

                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),

      // ── Bottom CTA ─────────────────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Semantics(
            button: true,
            label: l10n.home_scan_button,
            child: ElevatedButton(
              onPressed: () => _onScanPressed(context, ref),
              child: Text(l10n.home_scan_button),
            ),
          ),
        ),
      ),
    );
  }

  /// Returns a fully localised date string using the current app locale.
  /// e.g. "Mar 4, 2026" (en), "4 Nis 2026" (tr), "2026年3月4日" (ja)
  String _dateLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(DateTime.now());
  }

  String _statusMessage(AppLocalizations l10n, double fraction) {
    if (fraction >= 1.0) return l10n.home_status_danger;
    if (fraction >= 0.8) return l10n.home_status_warning;
    if (fraction >= 0.5) return l10n.home_status_caution;
    return l10n.home_status_safe;
  }
}

class _ErrorBadge extends StatelessWidget {
  const _ErrorBadge({required this.message});

  /// [message] is a localised string passed from the parent.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.coralRisk,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.uvDangerCoral,
        ),
      ),
    );
  }
}
