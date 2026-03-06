import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/services/ad_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/remote_config_service.dart';
import 'core/services/revenue_cat_service.dart';
import 'core/utils/logger.dart';
import 'features/onboarding/presentation/providers/onboarding_provider.dart';

/// Application entry point.
///
/// Initialisation order:
/// 1. Flutter binding
/// 2. Firebase Core (graceful fail if google-services.json not yet added)
/// 3. SharedPreferences (blocking — required before any provider reads it)
/// 4. Remote Config + Monetisation SDKs (non-blocking if they fail)
/// 5. ProviderScope with SharedPreferences override → runApp
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase must be initialised before RemoteConfigService and RevenueCat.
  // Fails gracefully when google-services.json / GoogleService-Info.plist
  // are not yet present — app continues with local FeatureToggles defaults.
  await _initFirebase();

  // Pre-initialise SharedPreferences so providers can read it synchronously.
  final prefs = await SharedPreferences.getInstance();

  await RemoteConfigService.init();
  await _bootstrapMonetisation();
  await NotificationService.init();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const UvDosimeterApp(),
    ),
  );
}

/// Initialises Firebase Core.
///
/// Catches all exceptions so a missing config file never crashes the app.
/// Once google-services.json / GoogleService-Info.plist are added, this
/// call succeeds and all Firebase services (RC, FCM) become available.
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();
    appLogger.i('[Firebase] Core initialised.');
  } catch (e, st) {
    appLogger.w(
      '[Firebase] Core init failed — Remote Config and FCM unavailable. '
      'Add google-services.json / GoogleService-Info.plist to activate.',
      error: e,
      stackTrace: st,
    );
  }
}

/// Initialises monetisation SDKs.
///
/// Both calls are silent no-ops while [FeatureToggles] flags are false.
/// When flags are enabled (via code or Remote Config), the SDKs activate
/// without any further changes.
Future<void> _bootstrapMonetisation() async {
  try {
    await RevenueCatService.init();
    await AdService.init();
  } catch (e, st) {
    appLogger.e('Monetisation bootstrap error', error: e, stackTrace: st);
  }
}
