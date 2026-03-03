import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/theme/app_theme.dart';
import 'router/app_router.dart';

/// Root application widget.
///
/// [MaterialApp.router] is configured with:
/// - [AppTheme.light]  — Bihaku clinical-white design tokens
/// - [appRouter]       — GoRouter with onboarding guard
/// - Three-locale support (en, ja, tr) via flutter_localizations
///
/// AppLocalizations delegate is added when `flutter gen-l10n`
/// generates lib/l10n/app_localizations.dart on build.
class UvDosimeterApp extends StatelessWidget {
  const UvDosimeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'UV Dosimeter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ja'),
        Locale('tr'),
      ],
    );
  }
}
