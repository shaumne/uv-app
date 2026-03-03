import 'package:flutter/material.dart';

/// Design token palette for the UV Dosimeter app.
///
/// Inspired by Japanese luxury skincare brands (Shiseido / POLA / SK-II).
/// Never hardcode hex values in widgets — always reference this class.
class AppColors {
  AppColors._();

  // ── Base surfaces ────────────────────────────────────────────────────────
  static const Color clinicalWhite = Color(0xFFF9F7F5);
  static const Color snowPearl = Color(0xFFFFFFFF);
  static const Color deepInk = Color(0xFF1A1A2E);

  // ── Status tints (UV exposure spectrum) ──────────────────────────────────
  static const Color sakuraMist = Color(0xFFF2E8F0);
  static const Color goldenCaution = Color(0xFFFFF3CD);
  static const Color coralRisk = Color(0xFFFFEAE6);

  // ── Semantic accent colours ───────────────────────────────────────────────
  static const Color uvSafeGreen = Color(0xFF4CAF8D);
  static const Color uvWarnAmber = Color(0xFFE8A838);
  static const Color uvDangerCoral = Color(0xFFE05C4B);
  static const Color bihakuLavender = Color(0xFFB8A9D9);

  // ── Card / divider / shimmer ──────────────────────────────────────────────
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color subtleDivider = Color(0xFFEEECEA);
  static const Color shimmerBase = Color(0xFFF0EDEA);
  static const Color shimmerHigh = Color(0xFFFAF8F6);

  // ── Overlay ───────────────────────────────────────────────────────────────
  static const Color scanVignette = Color(0xCC000000);
}
