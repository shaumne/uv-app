import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'route_names.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/skin_type_picker_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/scan/presentation/screens/scan_screen.dart';
import '../../features/result/presentation/screens/result_screen.dart';
import '../../features/result/domain/entities/uv_analysis_result.dart';

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
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);

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
