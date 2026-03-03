import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography scale for UV Dosimeter.
///
/// Display headings use DM Serif Display for a premium editorial feel.
/// Body and data text use Inter for clinical readability.
/// Both families are sourced from the google_fonts package — no local
/// font assets are required, which eliminates pubspec asset declarations.
class AppTypography {
  AppTypography._();

  static TextStyle get displayLarge => GoogleFonts.dmSerifDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: AppColors.deepInk,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineMed => GoogleFonts.dmSerifDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: AppColors.deepInk,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.deepInk,
        height: 1.6,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.deepInk,
        height: 1.5,
      );

  /// Large numeric readout — used for MED percentage or UV index value.
  static TextStyle get dataDisplay => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w300,
        color: AppColors.deepInk,
        letterSpacing: -1.5,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.deepInk.withValues(alpha: 0.55),
        letterSpacing: 1.2,
      );

  static TextStyle get buttonLabel => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );
}
