import 'package:flutter/material.dart';

import '../../../domain/entities/arrow_entity.dart';
import '../painting/arrow_impact_painter.dart';

/// One-shot "impact" flash played over an arrow when its exit is blocked by
/// another arrow. Calls [onComplete] when the flash finishes so the overlay
/// can be removed. Positioned over the whole board, same as
/// [ArrowExitAnimation].
class ArrowImpactAnimation extends StatefulWidget {
  const ArrowImpactAnimation({
    super.key,
    required this.arrow,
    required this.cell,
    required this.onComplete,
  });

  final ArrowEntity arrow;
  final double cell;
  final VoidCallback onComplete;

  @override
  State<ArrowImpactAnimation> createState() => _ArrowImpactAnimationState();
}

class _ArrowImpactAnimationState extends State<ArrowImpactAnimation>
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
          painter: ArrowImpactPainter(
            arrow: widget.arrow,
            cell: widget.cell,
            progress: _controller.value,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}
