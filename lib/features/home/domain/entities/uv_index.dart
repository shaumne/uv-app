import 'package:equatable/equatable.dart';

/// Represents the real-time UV Index for a geographic location.
///
/// [value] follows the WHO UV Index scale (0–11+).
/// [latitude] and [longitude] identify the measurement point.
class UvIndex extends Equatable {
  const UvIndex({
    required this.value,
    required this.latitude,
    required this.longitude,
    required this.fetchedAt,
  });

  final double value;
  final double latitude;
  final double longitude;
  final DateTime fetchedAt;

  /// Returns a human-readable risk category per WHO classification.
  String get riskCategory {
    if (value < 3) return 'Low';
    if (value < 6) return 'Moderate';
    if (value < 8) return 'High';
    if (value < 11) return 'Very High';
    return 'Extreme';
  }

  @override
  List<Object> get props => [value, latitude, longitude, fetchedAt];
}
