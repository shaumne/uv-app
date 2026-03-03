import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'core/services/ad_service.dart';
import 'core/services/remote_config_service.dart';
import 'core/services/revenue_cat_service.dart';
import 'core/utils/logger.dart';
import 'features/onboarding/presentation/providers/onboarding_provider.dart';

/// Application entry point.
///
/// Initialisation order:
/// 1. Flutter binding
/// 2. SharedPreferences (blocking — required before any provider reads it)
/// 3. Remote Config + Monetisation (non-blocking if they fail)
/// 4. ProviderScope with SharedPreferences override → runApp
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-initialise SharedPreferences so providers can read it synchronously.
  final prefs = await SharedPreferences.getInstance();

  await RemoteConfigService.init();
  await _bootstrapMonetisation();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const UvDosimeterApp(),
    ),
  );
}

/// Initialises monetisation SDKs.
/// Both calls are silent no-ops while [FeatureToggles] flags are false.
Future<void> _bootstrapMonetisation() async {
  try {
    await RevenueCatService.init();
    await AdService.init();
  } catch (e, st) {
    appLogger.e('Monetisation bootstrap error', error: e, stackTrace: st);
  }
}
