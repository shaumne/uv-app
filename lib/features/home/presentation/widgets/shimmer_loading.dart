import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Shimmer loading placeholder — from Premium_Cosmeceutical_UI_Designer skill.
///
/// Uses a sweeping LinearGradient from shimmerBase → shimmerHigh → shimmerBase.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 12,
    super.key,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + _animation.value * 2, 0),
              end: Alignment(1 + _animation.value * 2, 0),
              colors: const [
                AppColors.shimmerBase,
                AppColors.shimmerHigh,
                AppColors.shimmerBase,
              ],
            ),
          ),
        );
      },
    );
  }
}
