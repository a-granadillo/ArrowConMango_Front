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

/// Renders the puzzle board: a grid of cells with the arrows positioned over
/// the cells they occupy. Tapping an arrow reports its id via [onArrowTap].
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

  /// Palette cycled across arrows so neighbours are visually distinct.
  static const List<Color> _arrowColors = [
    AppColors.primary,
    AppColors.success,
    AppColors.difficultyMedium,
    AppColors.difficultyHard,
    AppColors.textDark,
    AppColors.danger,
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
    return AspectRatio(
      aspectRatio: cols / rows,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cell = constraints.maxWidth / cols;
          return DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.beige,
              borderRadius: BorderRadius.circular(cell * 0.25),
              border: Border.all(color: AppColors.textMuted, width: 3),
            ),
            child: Stack(
              children: [
                Positioned.fill(child: _grid()),
                for (var i = 0; i < arrows.length; i++)
                  _positionedArrow(arrows[i], i, cell),
                for (final exiting in exitingArrows)
                  _positionedExiting(exiting, cell),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _grid() {
    return Column(
      children: List.generate(
        rows,
        (r) => Expanded(
          child: Row(
            children: List.generate(
              cols,
              (c) => Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: (r + c).isEven ? AppColors.cream2 : AppColors.beige,
                    border: Border.all(
                      color: AppColors.cream,
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
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
