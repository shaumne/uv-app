import 'package:equatable/equatable.dart';

/// Full UV analysis result from the FastAPI backend.
///
/// Merges both ComputerVision_Colorimetry and Dermatology_Math_Engine
/// skill response schemas into one domain entity, plus sticker/cumulative
/// separation metadata for robust state handling.
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
    required this.cumulativeDoseJm2,
    required this.stickerDoseJm2,
    required this.previousCumulativeDoseJm2,
    required this.stickerResetSuspected,
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

  /// Server-reported cumulative UV dose for today in J/m².
  ///
  /// This is the value that should normally be persisted to dose history.
  final double cumulativeDoseJm2;

  /// UV dose implied by the current sticker reading alone (J/m²).
  ///
  /// Used to detect potential "new sticker" events when significantly
  /// lower than [previousCumulativeDoseJm2].
  final double stickerDoseJm2;

  /// Cumulative dose value sent by the client in the analyse request (J/m²).
  final double previousCumulativeDoseJm2;

  /// True when the backend suspects a sticker reset based on a large
  /// downward jump between [previousCumulativeDoseJm2] and [stickerDoseJm2].
  final bool stickerResetSuspected;

  bool get isSafe => riskLevel == 'safe';
  bool get isCaution => riskLevel == 'caution';
  bool get isWarning => riskLevel == 'warning';
  bool get isDanger => riskLevel == 'danger';
  bool get isExceeded => riskLevel == 'exceeded';

  bool get requiresAction => isDanger || isExceeded;

  double get medUsedPercent => (medUsedFraction * 100).clamp(0, 999);

  bool get isStickerResetSuspected => stickerResetSuspected;

  @override
  List<Object> get props => [
        hexColor,
        uvPercent,
        medUsedFraction,
        remainingMinutes,
        riskLevel,
        spfEffectiveNow,
        sunscreenReapplyRecommended,
        analyzedAt,
        cumulativeDoseJm2,
        stickerDoseJm2,
        previousCumulativeDoseJm2,
        stickerResetSuspected,
      ];
}
