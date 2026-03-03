/// REST API endpoint paths and header keys.
class ApiConstants {
  ApiConstants._();

  // ── FastAPI backend ───────────────────────────────────────────────────────
  static const String analyzeSticker = '/analyze';

  // ── UV Index external API (Open-Meteo / OpenUV) ───────────────────────────
  static const String uvIndex = '/uvi';

  // ── Multipart field names (must match FastAPI parameter names) ────────────
  static const String fieldImage = 'image';
  static const String fieldAmbientLux = 'ambient_lux';
  static const String fieldSkinType = 'skin_type';
  static const String fieldSpf = 'spf';
}
