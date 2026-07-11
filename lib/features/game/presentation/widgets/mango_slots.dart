import 'package:flutter/material.dart';

import '../../../../core/widgets/mango_logo.dart';

/// The victory dialog's 1-3 mango rating row: the middle icon is largest,
/// filled slots are full-color, unfilled ones are greyed out, and each pops
/// in with a staggered scale+rotate animation matching the design's
/// `mangoPop` keyframe.
class MangoSlots extends StatefulWidget {
  const MangoSlots({super.key, required this.filled});

  /// Number of filled (earned) mango slots, 1-3.
  final int filled;

  @override
  State<MangoSlots> createState() => _MangoSlotsState();
}

class _MangoSlotsState extends State<MangoSlots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 1; i <= 3; i++) ...[
          if (i > 1) const SizedBox(width: 14),
          _Slot(
            index: i,
            size: i == 2 ? 56 : 44,
            filled: i <= widget.filled,
            controller: _controller,
          ),
        ],
      ],
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.index,
    required this.size,
    required this.filled,
    required this.controller,
  });

  final int index;
  final double size;
  final bool filled;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    // Staggered delay: (0.25 + index * 0.18)s over the 0.95s controller.
    final delay = (0.25 + index * 0.18).clamp(0.0, 0.85);
    final anim = CurvedAnimation(
      parent: controller,
      curve: Interval(delay, 1.0, curve: Curves.elasticOut),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) => Transform.scale(
        scale: anim.value.clamp(0.0, 1.3),
        child: Opacity(opacity: filled ? 1 : 0.3, child: child),
      ),
      child: filled
          ? MangoLogo(size: size)
          : ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0, 0, 0, 1, 0,
              ]),
              child: MangoLogo(size: size),
            ),
    );
  }
}
