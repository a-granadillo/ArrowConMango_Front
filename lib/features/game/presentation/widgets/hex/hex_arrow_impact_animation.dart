import 'package:flutter/material.dart';

import '../../../domain/entities/arrow_entity.dart';
import 'hex_impact_painter.dart';

/// One-shot "impact" flash played over an arrow when its exit is blocked by
/// another arrow, on a hexagonal board — the hex sibling of
/// [ArrowImpactAnimation]. Positioned over the whole board.
class HexArrowImpactAnimation extends StatefulWidget {
  const HexArrowImpactAnimation({
    super.key,
    required this.arrow,
    required this.hexSize,
    required this.origin,
    required this.onComplete,
  });

  final ArrowEntity arrow;
  final double hexSize;
  final Offset origin;
  final VoidCallback onComplete;

  @override
  State<HexArrowImpactAnimation> createState() =>
      _HexArrowImpactAnimationState();
}

class _HexArrowImpactAnimationState extends State<HexArrowImpactAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 350),
    vsync: this,
  );

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
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: HexArrowImpactPainter(
            arrow: widget.arrow,
            hexSize: widget.hexSize,
            origin: widget.origin,
            progress: _controller.value,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}
