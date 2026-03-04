import 'package:flutter/material.dart';

/// Pulsing scan guide frame — from Premium_Cosmeceutical_UI_Designer skill.
///
/// Displays four L-shaped corner marks that form the sticker alignment guide.
/// The frame pulses continuously with a soft fade animation while waiting.
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
      child: const _ScanFrameCorners(),
    );
  }
}

/// Four L-shaped corner marks that form the sticker alignment guide frame.
class _ScanFrameCorners extends StatelessWidget {
  const _ScanFrameCorners();

  static const _size = 220.0;
  static const _cornerLength = 28.0;
  static const _strokeWidth = 3.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: CustomPaint(
        painter: _CornerPainter(
          color: Colors.white,
          strokeWidth: _strokeWidth,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    const len = _ScanFrameCorners._cornerLength;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // Top-left
    canvas
      ..drawLine(Offset(0, len), Offset.zero, paint)
      ..drawLine(Offset.zero, Offset(len, 0), paint)
      // Top-right
      ..drawLine(Offset(w - len, 0), Offset(w, 0), paint)
      ..drawLine(Offset(w, 0), Offset(w, len), paint)
      // Bottom-left
      ..drawLine(Offset(0, h - len), Offset(0, h), paint)
      ..drawLine(Offset(0, h), Offset(len, h), paint)
      // Bottom-right
      ..drawLine(Offset(w - len, h), Offset(w, h), paint)
      ..drawLine(Offset(w, h - len), Offset(w, h), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
