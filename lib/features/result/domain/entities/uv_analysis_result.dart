import 'package:equatable/equatable.dart';

/// Full UV analysis result from the FastAPI backend.
///
/// Merges both ComputerVision_Colorimetry and Dermatology_Math_Engine
/// skill response schemas into one domain entity.
class UvAnalysisResult extends Equatable {
  const UvAnalysisResult({
    required this.hexColor,
    required this.uvPercent,
    required this.medUsedFraction,
    required this.remainingMinutes,
    required this.riskLevel,
    required this.spfEffectiveNow,
    required this.sunscreenReapplyRecommended,
    required this.analyzedAt,
  });

  /// Dominant sticker colour in '#RRGGBB' format.
  final String hexColor;

  /// UV exposure percentage from L* calibration (0-100+).
  final double uvPercent;

  /// Cumulative MED fraction (0.0 = none, 1.0 = full MED, 1.0+ = over-exposed).
  final double medUsedFraction;

  /// Estimated remaining safe sun exposure in minutes.
  final int remainingMinutes;

  /// Risk tier: 'safe' | 'caution' | 'warning' | 'danger' | 'exceeded'.
  final String riskLevel;

  /// Current effective SPF after bi-exponential decay.
  final double spfEffectiveNow;

  /// True when SPF_eff has dropped below 50% of the applied SPF.
  final bool sunscreenReapplyRecommended;

  final DateTime analyzedAt;

  bool get isSafe => riskLevel == 'safe';
  bool get isCaution => riskLevel == 'caution';
  bool get isWarning => riskLevel == 'warning';
  bool get isDanger => riskLevel == 'danger';
  bool get isExceeded => riskLevel == 'exceeded';

  bool get requiresAction => isDanger || isExceeded;

  double get medUsedPercent => (medUsedFraction * 100).clamp(0, 999);

  @override
  List<Object> get props => [
        hexColor,
        uvPercent,
        medUsedFraction,
        remainingMinutes,
        riskLevel,
        analyzedAt,
      ];
}
