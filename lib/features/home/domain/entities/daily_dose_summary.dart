import 'package:equatable/equatable.dart';

/// Cumulative UV dose data for the current calendar day.
///
/// [medUsedFraction] is a value between 0.0 and 1.0+ representing
/// how much of the user's Minimal Erythema Dose has been consumed.
/// Values above 1.0 indicate over-exposure.
class DailyDoseSummary extends Equatable {
  const DailyDoseSummary({
    required this.medUsedFraction,
    required this.remainingMinutes,
    required this.date,
  });

  final double medUsedFraction;

  /// Estimated remaining safe sun exposure in minutes.
  /// 0 means the daily MED has been reached or exceeded.
  final int remainingMinutes;

  final DateTime date;

  double get medUsedPercent => (medUsedFraction * 100).clamp(0, 999);

  bool get isOverExposed => medUsedFraction >= 1.0;

  @override
  List<Object> get props => [medUsedFraction, remainingMinutes, date];
}
