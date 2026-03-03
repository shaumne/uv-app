import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/services/ad_service.dart';
import 'core/services/remote_config_service.dart';
import 'core/services/revenue_cat_service.dart';
import 'core/utils/logger.dart';

/// Application entry point.
///
/// Initialisation order is deliberate:
/// 1. Flutter binding
/// 2. Monetisation SDKs (no-ops when FeatureToggles are false)
/// 3. [ProviderScope] wraps the full widget tree for Riverpod DI
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase and Remote Config will be initialised here once
  // google-services.json / GoogleService-Info.plist are added.
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await RemoteConfigService.init();

  await RemoteConfigService.init();
  await _bootstrapMonetisation();

  runApp(
    const ProviderScope(
      child: UvDosimeterApp(),
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
    // Non-fatal: monetisation failure must never crash the app.
    appLogger.e('Monetisation bootstrap error', error: e, stackTrace: st);
  }
}
