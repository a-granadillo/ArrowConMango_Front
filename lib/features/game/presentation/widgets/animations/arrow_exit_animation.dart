import 'package:flutter/material.dart';

import '../../../domain/entities/arrow_entity.dart';
import '../painting/arrow_exit_painter.dart';
import '../painting/arrow_geometry.dart';

/// Animates one arrow sliding out of the board "snake" style: the stroke
/// advances along its own path (bends included) and off the edge, then calls
/// [onComplete] so the overlay can be removed. Positioned over the whole board.
class ArrowExitAnimation extends StatefulWidget {
  const ArrowExitAnimation({
    super.key,
    required this.arrow,
    required this.cell,
    required this.rows,
    required this.cols,
    required this.color,
    required this.onComplete,
  });

  final ArrowEntity arrow;
  final double cell;
  final int rows;
  final int cols;
  final Color color;
  final VoidCallback onComplete;

  @override
  State<ArrowExitAnimation> createState() => _ArrowExitAnimationState();
}

class _ArrowExitAnimationState extends State<ArrowExitAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: _durationFor(widget.arrow, widget.rows, widget.cols),
    vsync: this,
  );
  late final Animation<double> _t =
      CurvedAnimation(parent: _controller, curve: Curves.easeIn);

  static Duration _durationFor(ArrowEntity arrow, int rows, int cols) {
    final travel = arrow.length + exitCells(arrow, rows, cols);
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
          painter: ArrowExitPainter(
            arrow: widget.arrow,
            color: widget.color,
            cell: widget.cell,
            rows: widget.rows,
            cols: widget.cols,
            progress: _t.value,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}
