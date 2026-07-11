import 'package:flutter/material.dart';

import '../../../domain/entities/arrow_entity.dart';
import '../../../domain/entities/cardinal_direction.dart';
import '../../../domain/entities/direction.dart';
import '../arrow_widget.dart';

/// Slides an exited arrow off the board (in its direction) while fading out,
/// then calls [onComplete] so the overlay can be removed.
///
/// The parent positions this widget over the cells the arrow occupied.
class ArrowExitAnimation extends StatefulWidget {
  const ArrowExitAnimation({
    super.key,
    required this.arrow,
    required this.cellSize,
    required this.color,
    required this.onComplete,
  });

  final ArrowEntity arrow;
  final double cellSize;
  final Color color;
  final VoidCallback onComplete;

  @override
  State<ArrowExitAnimation> createState() => _ArrowExitAnimationState();
}

class _ArrowExitAnimationState extends State<ArrowExitAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 320),
    vsync: this,
  );
  late final Animation<double> _t =
      CurvedAnimation(parent: _controller, curve: Curves.easeIn);

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

  Offset _direction() {
    return switch (widget.arrow.direction) {
      CardinalDirection.up => const Offset(0, -1),
      CardinalDirection.down => const Offset(0, 1),
      CardinalDirection.left => const Offset(-1, 0),
      CardinalDirection.right => const Offset(1, 0),
      Direction() => Offset.zero,
    };
  }

  @override
  Widget build(BuildContext context) {
    final travel = widget.cellSize * (widget.arrow.length + 3);
    final dir = _direction();
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        return Transform.translate(
          offset: dir * travel * _t.value,
          child: Opacity(opacity: 1 - _t.value, child: child),
        );
      },
      child: IgnorePointer(
        child: ArrowWidget(
          arrow: widget.arrow,
          cellSize: widget.cellSize,
          color: widget.color,
        ),
      ),
    );
  }
}
