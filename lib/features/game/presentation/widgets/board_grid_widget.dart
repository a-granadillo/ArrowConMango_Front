import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/arrow_entity.dart';
import 'animations/arrow_exit_animation.dart';
import 'painting/arrows_layer_painter.dart';

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

/// Renders the puzzle board: a dark-wood frame around a dotted surface, with
/// arrows drawn as thin snake-like strokes (a single [ArrowsLayerPainter]).
///
/// Tapping is resolved by cell — the tapped pixel maps to a `(row, col)`, and
/// the arrow occupying that cell is reported via [onArrowTap]. This is exact
/// even for bent arrows whose bounding boxes overlap other arrows' cells.
class BoardGridWidget extends StatelessWidget {
  const BoardGridWidget({
    super.key,
    required this.rows,
    required this.cols,
    required this.arrows,
    required this.onArrowTap,
    required this.colorOf,
    this.exitingArrows = const [],
  });

  final int rows;
  final int cols;
  final List<ArrowEntity> arrows;
  final void Function(String arrowId) onArrowTap;

  /// Stable color for an arrow id (see [ArrowColorAssigner]).
  final Color Function(String id) colorOf;

  final List<ExitingArrowData> exitingArrows;

  void _handleTap(Offset local, double cell) {
    final col = (local.dx / cell).floor().clamp(0, cols - 1);
    final row = (local.dy / cell).floor().clamp(0, rows - 1);
    final key = '${row}_$col';
    for (final arrow in arrows) {
      if (arrow.occupiedNodes.any((n) => n.key == key)) {
        onArrowTap(arrow.id);
        return;
      }
    }
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
          BoxShadow(color: Color(0x526D4C2A), blurRadius: 28, offset: Offset(0, 8)),
        ],
      ),
      child: AspectRatio(
        aspectRatio: cols / rows,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cell = constraints.maxWidth / cols;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) => _handleTap(details.localPosition, cell),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _BoardSurfacePainter(cell)),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: ArrowsLayerPainter(
                          arrows: arrows,
                          colorOf: colorOf,
                          cell: cell,
                        ),
                      ),
                    ),
                    for (final exiting in exitingArrows)
                      Positioned.fill(
                        key: ValueKey(exiting.id),
                        child: ArrowExitAnimation(
                          arrow: exiting.arrow,
                          cell: cell,
                          rows: rows,
                          cols: cols,
                          color: exiting.color,
                          onComplete: exiting.onComplete,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
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
