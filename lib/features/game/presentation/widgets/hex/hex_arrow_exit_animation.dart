import 'package:flutter/material.dart';

import '../../../domain/entities/arrow_entity.dart';
import 'hex_exit_painter.dart';
import 'hex_geometry.dart';

/// Animates one arrow sliding out of a hexagonal board "snake" style — the
/// hex sibling of [ArrowExitAnimation]. Positioned over the whole board.
class HexArrowExitAnimation extends StatefulWidget {
  const HexArrowExitAnimation({
    super.key,
    required this.arrow,
    required this.hexSize,
    required this.radius,
    required this.origin,
    required this.color,
    required this.onComplete,
  });

  final ArrowEntity arrow;
  final double hexSize;
  final int radius;
  final Offset origin;
  final Color color;
  final VoidCallback onComplete;

  @override
  State<HexArrowExitAnimation> createState() => _HexArrowExitAnimationState();
}

class _HexArrowExitAnimationState extends State<HexArrowExitAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: _durationFor(widget.arrow, widget.radius),
    vsync: this,
  );
  late final Animation<double> _t =
      CurvedAnimation(parent: _controller, curve: Curves.easeIn);

  static Duration _durationFor(ArrowEntity arrow, int radius) {
    final travel = arrow.length + exitCells(arrow, radius);
    return Duration(milliseconds: (140 + travel * 45).clamp(250, 700));
  }

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onComplete();
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, _) => CustomPaint(
          painter: HexArrowExitPainter(
            arrow: widget.arrow,
            color: widget.color,
            hexSize: widget.hexSize,
            radius: widget.radius,
            origin: widget.origin,
            progress: _t.value,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}
