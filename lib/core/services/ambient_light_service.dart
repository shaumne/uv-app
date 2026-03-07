import 'package:ambient_light/ambient_light.dart';

import '../utils/logger.dart';

/// Provides current ambient light (lux) for scan analysis.
///
/// Used when sending the sticker image to the backend so white-balance
/// can be adjusted. Falls back to 500 lux (overcast outdoor) if the sensor
/// is unavailable or fails.
class AmbientLightService {
  AmbientLightService() : _sensor = AmbientLight();

  final AmbientLight _sensor;

  /// Default lux when sensor is unavailable (conservative overcast outdoor).
  static const double fallbackLux = 500.0;

  /// Returns current ambient light in lux, or [fallbackLux] if unavailable.
  Future<double> getCurrentLux() async {
    try {
      final lux = await _sensor.currentAmbientLight();
      if (lux != null && lux >= 0) {
        appLogger.d('[AmbientLight] Sensor: ${lux.toStringAsFixed(0)} lux');
        return lux;
      }
    } catch (e, st) {
      appLogger.w('[AmbientLight] Sensor unavailable, using fallback', error: e, stackTrace: st);
    }
    return fallbackLux;
  }
}
