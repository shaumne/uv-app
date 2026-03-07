import 'package:flutter/material.dart';

/// Pulsing scan guide — from Premium_Cosmeceutical_UI_Designer skill.
///
/// Displays a circle that matches the backend ROI: user places the sticker
/// inside this circle and captures; the app reads only the centre region.
/// The circle pulses with a soft fade while the camera is idle.
class PulseOverlayFrame extends StatefulWidget {
  const PulseOverlayFrame({super.key});

  @override
  State<PulseOverlayFrame> createState() => _PulseOverlayFrameState();
}

class _PulseOverlayFrameState extends State<PulseOverlayFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: const _ScanFrameCircle(),
    );
  }
}

/// Circle guide sized to encompass the sticker; backend reads the centre ROI.
class _ScanFrameCircle extends StatelessWidget {
  const _ScanFrameCircle();

  /// Diameter: sticker'ı kapsayacak boyut; daha küçük = daha uzak çekim, daha iyi netlik.
  static const _diameter = 176.0;
  static const _strokeWidth = 3.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _diameter,
      height: _diameter,
      child: CustomPaint(
        painter: _CircleGuidePainter(
          color: Colors.white70,
          strokeWidth: _strokeWidth,
        ),
      ),
    );
  }
}

class _CircleGuidePainter extends CustomPainter {
  const _CircleGuidePainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_CircleGuidePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
