import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uv_dosimeter/l10n/app_localizations.dart';
import 'route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/skin_type_picker_screen.dart';
import '../../features/premium/screens/premium_upsell_sheet.dart';
import '../../features/result/domain/entities/uv_analysis_result.dart';
import '../../features/result/presentation/screens/result_screen.dart';
import '../../features/scan/presentation/screens/scan_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

/// Provider that exposes the router — allows GoRouter to listen to
/// Riverpod state for auth/onboarding redirects.
final routerProvider = Provider<GoRouter>((ref) => appRouter);

/// Application router with onboarding guard redirect.
///
/// Checks SharedPreferences for the 'onboarding_complete' flag.
/// If absent → redirects to /onboarding.
/// All transitions use a premium fade+slide (280ms, easeOutCubic).
final appRouter = GoRouter(
  initialLocation: RouteNames.home,
  debugLogDiagnostics: !const bool.fromEnvironment('dart.vm.product'),
  redirect: (context, state) async {
    // Skip guard for onboarding routes themselves
    final loc = state.uri.toString();
    if (loc.startsWith(RouteNames.onboarding)) return null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final isOnboarded = prefs.getBool('onboarding_complete') ?? false;
      if (!isOnboarded) return RouteNames.onboarding;
    } catch (_) {
      // If prefs fails, allow through — don't block app startup
    }
    return null;
  },
  routes: [
    GoRoute(
      path: RouteNames.onboarding,
      pageBuilder: (context, state) =>
          _fadeSlide(const OnboardingScreen(), state),
    ),
    GoRoute(
      path: RouteNames.skinTypePicker,
      pageBuilder: (context, state) =>
          _fadeSlide(const SkinTypePickerScreen(), state),
    ),
    GoRoute(
      path: RouteNames.home,
      pageBuilder: (context, state) =>
          _fadeSlide(const HomeScreen(), state),
    ),
    GoRoute(
      path: RouteNames.scan,
      pageBuilder: (context, state) =>
          _fadeSlide(const ScanScreen(), state),
    ),
    GoRoute(
      path: RouteNames.result,
      pageBuilder: (context, state) {
        final result = state.extra as UvAnalysisResult;
        return _fadeSlide(ResultScreen(result: result), state);
      },
    ),
    GoRoute(
      path: RouteNames.settings,
      pageBuilder: (context, state) =>
          _fadeSlide(const SettingsScreen(), state),
    ),
    GoRoute(
      path: RouteNames.history,
      pageBuilder: (context, state) =>
          _fadeSlide(const HistoryScreen(), state),
    ),
    GoRoute(
      path: RouteNames.premiumUpsell,
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const _PremiumUpsellPage(),
        transitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
      ),
    ),
  ],
  errorBuilder: (context, state) => _NotFoundScreen(uri: state.uri.toString()),
);

// ── Premium upsell full-screen wrapper ───────────────────────────────────────

/// Wraps [PremiumUpsellSheet] in a dismissible scaffold so it can be
/// navigated to as a full-screen route (not only a bottom sheet).
class _PremiumUpsellPage extends StatelessWidget {
  const _PremiumUpsellPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(height: 80),
          ),
          const PremiumUpsellSheet(),
        ],
      ),
    );
  }
}

// ── 404 / Route not found screen ─────────────────────────────────────────────

/// Styled error screen shown when a navigation target cannot be found.
///
/// Replaces the default raw [Text] error builder with a Bihaku-themed page
/// that guides the user back to the home screen.
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({required this.uri});
  final String uri;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.clinicalWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.subtleDivider,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PhosphorIcon(
                  PhosphorIconsRegular.magnifyingGlassMinus,
                  size: 36,
                  color: AppColors.deepInk,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.error_pageNotFound_title,
                style: AppTypography.headlineMed,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.error_pageNotFound_message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.deepInk.withValues(alpha: 0.55),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go(RouteNames.home),
                  child: Text(l10n.result_backHome),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Page transition ───────────────────────────────────────────────────────────

/// Premium fade+upward-slide page transition (280ms, easeOutCubic).
CustomTransitionPage<void> _fadeSlide(Widget child, GoRouterState state) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade =
            CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
