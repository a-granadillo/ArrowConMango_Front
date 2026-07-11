import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/arrow_entity.dart';
import '../../domain/entities/cardinal_direction.dart';
import '../../domain/entities/direction.dart';

/// Visual for a single arrow piece. Fills the box the board positions it in
/// (spanning its occupied cells) and points a chevron toward its head.
class ArrowWidget extends StatelessWidget {
  const ArrowWidget({
    super.key,
    required this.arrow,
    required this.cellSize,
    this.color = AppColors.textDark,
  });

  final ArrowEntity arrow;
  final double cellSize;
  final Color color;

  static IconData iconFor(Direction direction) {
    return switch (direction) {
      CardinalDirection.up => Icons.keyboard_arrow_up_rounded,
      CardinalDirection.down => Icons.keyboard_arrow_down_rounded,
      CardinalDirection.left => Icons.keyboard_arrow_left_rounded,
      CardinalDirection.right => Icons.keyboard_arrow_right_rounded,
      _ => Icons.circle,
    };
  }

  static Alignment _headAlignment(Direction direction) {
    return switch (direction) {
      CardinalDirection.up => Alignment.topCenter,
      CardinalDirection.down => Alignment.bottomCenter,
      CardinalDirection.left => Alignment.centerLeft,
      CardinalDirection.right => Alignment.centerRight,
      _ => Alignment.center,
    };
  }

  @override
  Widget build(BuildContext context) {
    final inset = cellSize * 0.10;
    return Padding(
      padding: EdgeInsets.all(inset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(cellSize * 0.28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Align(
          alignment: _headAlignment(arrow.direction),
          child: Icon(
            iconFor(arrow.direction),
            color: AppColors.cream,
            size: cellSize * 0.7,
          ),
        ),
      ),
    );
  }
}
