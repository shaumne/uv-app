import 'package:equatable/equatable.dart';

/// WHO UV Index risk levels — locale-independent keys.
enum UvRiskLevel { low, moderate, high, veryHigh, extreme }

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

  /// Returns an opaque risk level key for lookup in the UI layer.
  ///
  /// Domain entities must not contain locale-specific strings.
  /// Consumers should use [UvRiskLevel] + [AppLocalizations] to display text.
  UvRiskLevel get riskLevel {
    if (value < 3) return UvRiskLevel.low;
    if (value < 6) return UvRiskLevel.moderate;
    if (value < 8) return UvRiskLevel.high;
    if (value < 11) return UvRiskLevel.veryHigh;
    return UvRiskLevel.extreme;
  }

  @override
  List<Object> get props => [value, latitude, longitude, fetchedAt];
}
