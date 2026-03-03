import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Arc gauge showing cumulative UV dose — built from Premium_Cosmeceutical_UI_Designer skill.
///
/// Animates from 0 to [percentage] on mount using [TweenAnimationBuilder].
/// Arc colour transitions through uvSafeGreen → uvWarnAmber → uvDangerCoral
/// at the 50% and 80% thresholds.
class UvArcGauge extends StatelessWidget {
  const UvArcGauge({
    required this.percentage,
    super.key,
  });

  /// Value between 0.0 and 1.0+ (over 1.0 = over-exposed).
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percentage.clamp(0, 1.15)),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, animatedPct, _) {
        final color = _gaugeColor(animatedPct);
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(200, 200),
                painter: _UvArcGaugePainter(
                  percentage: animatedPct,
                  arcColor: color,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(animatedPct * 100).toStringAsFixed(0)}%',
                    style: AppTypography.dataDisplay.copyWith(color: color),
                  ),
                  Text(
                    'of daily limit',
                    style: AppTypography.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Returns arc colour based on consumed percentage (skill spec: 50% / 80% thresholds).
  Color _gaugeColor(double pct) => pct < 0.5
      ? AppColors.uvSafeGreen
      : pct < 0.8
          ? AppColors.uvWarnAmber
          : AppColors.uvDangerCoral;
}

class _UvArcGaugePainter extends CustomPainter {
  const _UvArcGaugePainter({
    required this.percentage,
    required this.arcColor,
  });

  final double percentage;
  final Color arcColor;

  static const _startAngle = pi * 0.75;
  static const _sweepTotal = pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = AppColors.subtleDivider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // Background track
    canvas.drawArc(rect, _startAngle, _sweepTotal, false, trackPaint);

    if (percentage <= 0) return;

    // Active arc with gradient
    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: _startAngle,
        endAngle: _startAngle + _sweepTotal * percentage,
        colors: [arcColor.withValues(alpha: 0.7), arcColor],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      _startAngle,
      _sweepTotal * percentage.clamp(0, 1),
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_UvArcGaugePainter old) =>
      old.percentage != percentage || old.arcColor != arcColor;
}
