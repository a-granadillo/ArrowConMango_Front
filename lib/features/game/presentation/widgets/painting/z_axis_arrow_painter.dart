import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../three_d/board_3d_view.dart';
import 'arrow_geometry.dart';
import 'z_axis_geometry.dart';

/// Draws every axial (Z-facing) arrow on a 3D board layer as a small glyph at
/// its cell center: ⊙ for [ZFacing.forward] (toward the player), ⊗ for
/// [ZFacing.backward] (into the board).
///
/// Mirrors [ArrowsLayerPainter]'s shape — a shadow pass then a color pass,
/// both scaled by [opacity] — so axial ghosts from adjacent Z-layers read
/// consistently with planar ghosts.
class ZAxisArrowPainter extends CustomPainter {
  ZAxisArrowPainter({
    required this.arrows,
    required this.colorOf,
    required this.cell,
    this.opacity = 1.0,
  });

  final List<AxialArrow3D> arrows;
  final Color Function(String id) colorOf;
  final double cell;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidthFor(cell) * 0.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()..style = PaintingStyle.fill;

    for (final arrow in arrows) {
      final center = cellCenter(arrow.cell.row, arrow.cell.col, cell);
      final ring = buildGlyphRing(center, cell);
      final mark = switch (arrow.facing) {
        ZFacing.forward => buildForwardDot(center, cell),
        ZFacing.backward => buildBackwardCross(center, cell),
      };

      // Shadow pass.
      canvas.save();
      canvas.translate(kArrowShadowOffset.dx, kArrowShadowOffset.dy);
      final shadow = kArrowShadowColor.withValues(
        alpha: kArrowShadowColor.a * opacity,
      );
      ringPaint.color = shadow;
      canvas.drawPath(ring, ringPaint);
      if (arrow.facing == ZFacing.forward) {
        fillPaint.color = shadow;
        canvas.drawPath(mark, fillPaint);
      } else {
        canvas.drawPath(mark, ringPaint);
      }
      canvas.restore();

      // Color pass.
      final color = colorOf(arrow.id);
      final scaled = color.withValues(alpha: color.a * opacity);
      ringPaint.color = scaled;
      canvas.drawPath(ring, ringPaint);
      if (arrow.facing == ZFacing.forward) {
        fillPaint.color = scaled;
        canvas.drawPath(mark, fillPaint);
      } else {
        canvas.drawPath(mark, ringPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ZAxisArrowPainter old) =>
      old.cell != cell ||
      old.opacity != opacity ||
      !listEquals(old.arrows, arrows);
}
