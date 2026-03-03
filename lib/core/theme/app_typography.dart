import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography scale for UV Dosimeter.
///
/// Display headings use DM Serif Display for a premium editorial feel.
/// Body and data text use Inter for clinical readability.
class AppTypography {
  AppTypography._();

  static const String _serif = 'DMSerifDisplay';
  static const String _sans = 'Inter';

  static TextStyle get displayLarge => const TextStyle(
        fontFamily: _serif,
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: AppColors.deepInk,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineMed => const TextStyle(
        fontFamily: _serif,
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: AppColors.deepInk,
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: _sans,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.deepInk,
        height: 1.6,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: _sans,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.deepInk,
        height: 1.5,
      );

  /// Large numeric readout — used for MED percentage or UV index value.
  static TextStyle get dataDisplay => const TextStyle(
        fontFamily: _sans,
        fontSize: 48,
        fontWeight: FontWeight.w300,
        color: AppColors.deepInk,
        letterSpacing: -1.5,
      );

  static TextStyle get labelSmall => TextStyle(
        fontFamily: _sans,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.deepInk.withValues(alpha: 0.55),
        letterSpacing: 1.2,
      );

  static TextStyle get buttonLabel => const TextStyle(
        fontFamily: _sans,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );
}
