import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uv_dosimeter/l10n/app_localizations.dart';
import '../core/providers/locale_provider.dart';
import '../core/theme/app_theme.dart';
import 'router/app_router.dart';

/// Root application widget.
///
/// [MaterialApp.router] is configured with:
/// - [AppTheme.light]     — Bihaku clinical-white design tokens
/// - [appRouter]          — GoRouter with onboarding guard
/// - Dynamic locale       — driven by [localeNotifierProvider] (persisted to SharedPreferences)
/// - Three-locale support — en, ja, tr via flutter_localizations
class UvDosimeterApp extends ConsumerWidget {
  const UvDosimeterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeNotifierProvider);

    return MaterialApp.router(
      title: 'UV Dosimeter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      // Drive locale from user setting; falls back to device locale when null.
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
    );
  }
}
