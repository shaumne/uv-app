/// Dermatological and photobiological constants used across the app.
///
/// All MED baseline values are sourced from:
/// WHO UV Index Global Standard (2002) and ICNIRP UV exposure guidelines.
class UvConstants {
  UvConstants._();

  /// Minimum Erythema Dose baselines (in J/m²) per Fitzpatrick skin type
  /// under standard UV-B conditions (no sunscreen).
  /// Source: ICNIRP 2004 / CIE photobiology standards (matches backend MED_TABLE).
  static const Map<int, double> medBaselineJoules = {
    1: 200,  // Type I  — Always burns, never tans
    2: 250,  // Type II — Usually burns, sometimes tans
    3: 350,  // Type III — Sometimes burns, always tans
    4: 500,  // Type IV — Rarely burns, always tans
    5: 700,  // Type V  — Very rarely burns
    6: 1000, // Type VI — Never burns
  };

  /// UV irradiance per UV Index unit (W/m²), WHO standard.
  static const double uvIrradiancePerIndex = 0.025;

  /// Fraction of daily MED that triggers a "warning" notification.
  static const double warnThreshold = 0.5;

  /// Fraction of daily MED that triggers a "danger" notification.
  static const double dangerThreshold = 0.8;

  /// Maximum SPF value accepted from user input.
  static const int maxSpf = 100;

  /// Default SPF when user has not applied sunscreen.
  static const int defaultSpf = 1;
}
