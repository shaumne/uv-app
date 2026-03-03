import '../../domain/entities/uv_index.dart';

/// JSON model for the Open-Meteo UV index API response.
///
/// Endpoint: GET https://currentuvindex.com/api/v1/uvi?lat=&lng=
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

  factory UvIndexModel.fromJson(
    Map<String, dynamic> json,
    double latitude,
    double longitude,
  ) {
    // currentuvindex.com returns {"ok":true,"uvi":{"uvi":5.3,...}}
    final uvi = json['uvi'] as Map<String, dynamic>?;
    final rawValue = uvi?['uvi'] ?? json['uvi'] ?? 0.0;
    return UvIndexModel(
      value: (rawValue as num).toDouble(),
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
