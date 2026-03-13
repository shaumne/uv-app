import 'package:equatable/equatable.dart';

/// Dynamic profile parameter: increases when UV limits exceeded (penalty),
/// decreases when protected (reward). Based on biological age.
///
/// Used for gamification — "Sun Age" reflects cumulative UV exposure impact.
class SunAge extends Equatable {
  const SunAge({
    required this.value,
    required this.biologicalAge,
    required this.lastUpdated,
  });

  /// Sun Age value — can exceed biological age when over-exposed.
  final double value;

  /// User's biological age (baseline).
  final int biologicalAge;

  final DateTime lastUpdated;

  @override
  List<Object> get props => [value, biologicalAge, lastUpdated];
}
