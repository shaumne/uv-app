import 'package:flutter/material.dart';

/// Staggered slide+fade reveal for result cards.
///
/// From Premium_Cosmeceutical_UI_Designer skill:
///   intervals: 0.0-0.4 card0, 0.2-0.6 card1, 0.4-0.8 card2
/// Each card slides up from Offset(0, 0.18) with easeOutCubic.
class StaggeredRevealWrapper extends StatefulWidget {
  const StaggeredRevealWrapper({
    required this.index,
    required this.child,
    super.key,
  });

  /// Card index determines stagger delay (0-based).
  final int index;
  final Widget child;

  @override
  State<StaggeredRevealWrapper> createState() => _StaggeredRevealWrapperState();
}

class _StaggeredRevealWrapperState extends State<StaggeredRevealWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    final start = widget.index * 0.2;
    final end = (0.6 + widget.index * 0.2).clamp(0.0, 1.0);
    final interval = Interval(start, end, curve: Curves.easeOutCubic);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: interval));

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: interval),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}
