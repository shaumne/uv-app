/// Centralised application configuration.
///
/// Environment-specific values are injected at build time via `--dart-define`
/// so that no environment-specific strings are hardcoded in source.
///
/// Usage examples:
///   AWS EC2 (production backend):
///     flutter run --dart-define=API_BASE_URL=http://16.170.120.34:8000/api/v1
///
///   Development — fiziksel cihaz (LAN):
///     flutter run --dart-define=API_BASE_URL=http://10.20.10.154:8000/api/v1
///
///   Development — Android emülatör (localhost):
///     flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
///
///   Staging:
///     flutter run --dart-define=API_BASE_URL=https://staging.uvdosimetry.com/api/v1
///
///   Production:
///     flutter build apk --dart-define=API_BASE_URL=https://api.uvdosimetry.com/api/v1
///
/// When `API_BASE_URL` is not provided, the default is the EC2 backend.
class AppConfig {
  AppConfig._();

  // ── API ──────────────────────────────────────────────────────────────────
  /// Backend base URL. Injected via `--dart-define=API_BASE_URL=...`.
  /// Default: AWS EC2 instance (eu-north-1).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://16.170.120.34:8000/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 60);

  // ── UV Index data source (Open-Meteo, no API key required) ───────────────
  static const String uvIndexBaseUrl = 'https://currentuvindex.com/api/v1';

  // ── App metadata ─────────────────────────────────────────────────────────
  static const String appName = 'UV Dosimeter';
  static const String supportEmail = 'support@uvdosimetry.com';
}
