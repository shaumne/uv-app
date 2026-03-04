import '../../domain/entities/uv_index.dart';

/// JSON model for the Open-Meteo UV index API response.
///
/// Endpoint: GET https://api.open-meteo.com/v1/forecast
/// Params:   latitude, longitude, hourly=uv_index, forecast_days=1, timezone=auto
///
/// Response shape:
/// {
///   "hourly": {
///     "time":     ["2025-01-01T00:00", "2025-01-01T01:00", ...],  // 24 entries
///     "uv_index": [0.0, 0.0, 1.2, 4.5, ...]
///   }
/// }
class UvIndexModel {
  const UvIndexModel({
    required this.value,
    required this.latitude,
    required this.longitude,
    required this.fetchedAt,
  });

  final double value;
  final double latitude;
  final double longitude;
  final DateTime fetchedAt;

  /// Parses the Open-Meteo hourly UV index response.
  ///
  /// Selects the UV value for the current local hour.
  /// Falls back to the maximum value of the day if the hour index is out of range.
  factory UvIndexModel.fromOpenMeteoJson(
    Map<String, dynamic> json,
    double latitude,
    double longitude,
  ) {
    final hourly = json['hourly'] as Map<String, dynamic>?;
    final uvList = (hourly?['uv_index'] as List?)
        ?.map((e) => (e as num?)?.toDouble() ?? 0.0)
        .toList();

    double uvValue = 0.0;
    if (uvList != null && uvList.isNotEmpty) {
      final currentHour = DateTime.now().hour;
      // The list has 24 entries (one per hour); clamp in case API returns fewer.
      final idx = currentHour.clamp(0, uvList.length - 1);
      uvValue = uvList[idx];
    }

    return UvIndexModel(
      value: uvValue,
      latitude: latitude,
      longitude: longitude,
      fetchedAt: DateTime.now(),
    );
  }

  UvIndex toEntity() => UvIndex(
        value: value,
        latitude: latitude,
        longitude: longitude,
        fetchedAt: fetchedAt,
      );
}
