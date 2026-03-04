import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../utils/logger.dart';

/// Key used to persist the user-selected locale in SharedPreferences.
const _kLocaleKey = 'app_locale';

/// Supported locales for the application.
const supportedLocales = [
  Locale('en'),
  Locale('tr'),
  Locale('ja'),
];

/// Display names for each locale (shown in the settings UI).
const localeDisplayNames = {
  'en': 'English',
  'tr': 'Türkçe',
  'ja': '日本語',
};

// ── Notifier ──────────────────────────────────────────────────────────────────

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._ref) : super(const Locale('en')) {
    _resolveLocale();
  }

  final Ref _ref;

  /// Locale resolution priority:
  /// 1. User's explicit choice stored in SharedPreferences.
  /// 2. Device locale, if it matches one of the supported languages.
  /// 3. English fallback.
  void _resolveLocale() {
    final prefs = _ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(_kLocaleKey);

    if (saved != null) {
      // Explicit user preference always wins.
      final locale = _matchLocale(saved);
      state = locale;
      appLogger.d('[Locale] Restored user preference: $saved');
      return;
    }

    // No saved preference — try to match device locale.
    final deviceLocales =
        WidgetsBinding.instance.platformDispatcher.locales;

    for (final deviceLocale in deviceLocales) {
      final match = _matchLocale(deviceLocale.languageCode);
      if (match.languageCode != 'en' ||
          deviceLocale.languageCode == 'en') {
        // Found a supported language that isn't the English fallback,
        // OR the device language IS English.
        state = match;
        appLogger.d(
          '[Locale] Using device locale: '
          '${deviceLocale.languageCode} → ${match.languageCode}',
        );
        return;
      }
    }

    // No match found — stay on English fallback.
    appLogger.d('[Locale] No device locale match, defaulting to en');
  }

  /// Returns the supported [Locale] for [languageCode], or `en` as fallback.
  Locale _matchLocale(String languageCode) => supportedLocales.firstWhere(
        (l) => l.languageCode == languageCode,
        orElse: () => const Locale('en'),
      );

  /// Changes the app locale and immediately persists the choice.
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    state = locale;
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setString(_kLocaleKey, locale.languageCode);
    appLogger.i('[Locale] Locale set to: ${locale.languageCode}');
  }
}

final localeNotifierProvider =
    StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(ref),
);
