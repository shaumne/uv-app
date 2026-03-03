import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Builds the global [ThemeData] for the UV Dosimeter app.
///
/// Enforces the Bihaku design language — clinical white surfaces,
/// pastel status tints, and Inter/DM Serif typography scale.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.clinicalWhite,
      colorScheme: const ColorScheme.light(
        primary: AppColors.bihakuLavender,
        secondary: AppColors.uvSafeGreen,
        error: AppColors.uvDangerCoral,
        surface: AppColors.cardSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.clinicalWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        titleTextStyle: AppTypography.headlineMed,
        iconTheme: const IconThemeData(color: AppColors.deepInk),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.subtleDivider),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bihakuLavender,
          foregroundColor: AppColors.snowPearl,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTypography.buttonLabel,
          elevation: 0,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        headlineMedium: AppTypography.headlineMed,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        labelSmall: AppTypography.labelSmall,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.subtleDivider,
        thickness: 1,
        space: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.subtleDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.subtleDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.bihakuLavender, width: 1.5),
        ),
      ),
    );
  }
}
