/// Centralised application configuration.
///
/// Environment-specific values (base URL, timeouts) live here so that
/// no magic strings are scattered across the codebase.
class AppConfig {
  AppConfig._();

  // ── API ──────────────────────────────────────────────────────────────────
  // Use the machine's LAN IP so physical devices on the same WiFi can reach
  // the dev server. Replace with a real domain before shipping to production.
  static const String baseUrl = 'http://192.168.3.58:8000/api/v1';
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 60);

  // ── UV Index data source (Open-Meteo, no API key required) ───────────────
  static const String uvIndexBaseUrl = 'https://currentuvindex.com/api/v1';

  // ── App metadata ─────────────────────────────────────────────────────────
  static const String appName = 'UV Dosimeter';
  static const String supportEmail = 'support@uvdosimetry.com';
}
