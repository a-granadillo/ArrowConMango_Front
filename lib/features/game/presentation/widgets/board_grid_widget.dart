import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/arrow_entity.dart';
import '../../domain/entities/node_id.dart';
import 'animations/arrow_exit_animation.dart';
import 'arrow_widget.dart';

/// A just-removed arrow, rendered as a one-shot exit animation overlay.
class ExitingArrowData {
  const ExitingArrowData({
    required this.id,
    required this.arrow,
    required this.color,
    required this.onComplete,
  });

  final String id;
  final ArrowEntity arrow;
  final Color color;
  final VoidCallback onComplete;
}

/// Renders the puzzle board exactly as designed: a dark-wood frame around a
/// dotted board surface, with arrows positioned over the cells they occupy.
/// Tapping an arrow reports its id via [onArrowTap].
class BoardGridWidget extends StatelessWidget {
  const BoardGridWidget({
    super.key,
    required this.rows,
    required this.cols,
    required this.arrows,
    required this.onArrowTap,
    this.exitingArrows = const [],
  });

  final int rows;
  final int cols;
  final List<ArrowEntity> arrows;
  final void Function(String arrowId) onArrowTap;
  final List<ExitingArrowData> exitingArrows;

  /// Arrow color palette, in the exact order used by the design.
  static const List<Color> _arrowColors = [
    AppColors.mango,
    AppColors.danger,
    AppColors.primary,
    AppColors.success,
    AppColors.difficultyMedium,
    AppColors.difficultyHard,
    AppColors.difficultyEasy,
  ];

  /// Stable color for the arrow at [index] in the board's arrow list.
  static Color colorForIndex(int index) =>
      _arrowColors[index % _arrowColors.length];

  static (int row, int col) _rc(NodeId node) {
    final parts = node.key.split('_');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }

  (double left, double top, double width, double height) _bounds(
    ArrowEntity arrow,
    double cell,
  ) {
    var minRow = rows, minCol = cols, maxRow = 0, maxCol = 0;
    for (final node in arrow.occupiedNodes) {
      final (row, col) = _rc(node);
      minRow = row < minRow ? row : minRow;
      minCol = col < minCol ? col : minCol;
      maxRow = row > maxRow ? row : maxRow;
      maxCol = col > maxCol ? col : maxCol;
    }
    return (
      minCol * cell,
      minRow * cell,
      (maxCol - minCol + 1) * cell,
      (maxRow - minRow + 1) * cell,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Design frame: dark wood #6D4C2A, radius 22, padding 9, matching shadow.
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.textDark,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x526D4C2A),
            blurRadius: 28,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: cols / rows,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cell = constraints.maxWidth / cols;
            return ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _BoardSurfacePainter(cell)),
                  ),
                  for (var i = 0; i < arrows.length; i++)
                    _positionedArrow(arrows[i], i, cell),
                  for (final exiting in exitingArrows)
                    _positionedExiting(exiting, cell),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _positionedArrow(ArrowEntity arrow, int index, double cell) {
    final (left, top, width, height) = _bounds(arrow, cell);
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () => onArrowTap(arrow.id),
        child: ArrowWidget(
          arrow: arrow,
          cellSize: cell,
          color: colorForIndex(index),
        ),
      ),
    );
  }

  Widget _positionedExiting(ExitingArrowData exiting, double cell) {
    final (left, top, width, height) = _bounds(exiting.arrow, cell);
    return Positioned(
      key: ValueKey(exiting.id),
      left: left,
      top: top,
      width: width,
      height: height,
      child: ArrowExitAnimation(
        arrow: exiting.arrow,
        cellSize: cell,
        color: exiting.color,
        onComplete: exiting.onComplete,
      ),
    );
  }
}

/// Paints the board's dark backdrop with a subtle dotted pattern, matching
/// the design's `rgba(0,0,0,0.16)` fill + dotted `rgba(255,248,238,0.13)`
/// pattern (36px spacing at the design's reference scale).
class _BoardSurfacePainter extends CustomPainter {
  const _BoardSurfacePainter(this.cell);

  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0x29000000),
    );

    final dotPaint = Paint()..color = const Color(0x21FFF8EE);
    final spacing = cell;
    final dotRadius = cell * 0.05;
    for (var y = spacing / 2; y < size.height; y += spacing) {
      for (var x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BoardSurfacePainter oldDelegate) =>
      oldDelegate.cell != cell;
}
