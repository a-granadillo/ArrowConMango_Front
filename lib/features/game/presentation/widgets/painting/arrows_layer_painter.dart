import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../../domain/entities/arrow_entity.dart';
import 'arrow_geometry.dart';

/// Draws every live arrow on the board in one pass as a thin stroked polyline
/// (tail→head) with a V arrowhead and a flat drop shadow, matching the design.
///
/// [opacity] scales both the shadow and color passes uniformly (1.0 = fully
/// opaque). Used to render ghosted arrows from adjacent Z-layers in the 3D
/// board without a separate painter.
class ArrowsLayerPainter extends CustomPainter {
  ArrowsLayerPainter({
    required this.arrows,
    required this.colorOf,
    required this.cell,
    this.opacity = 1.0,
  });

  final List<ArrowEntity> arrows;
  final Color Function(String id) colorOf;
  final double cell;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidthFor(cell)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final arrow in arrows) {
      final body = buildBodyPath(arrow, cell);
      final (hr, hc) = rc(arrow.headNode);
      final head = buildChevron(
        cellCenter(hr, hc, cell),
        unitVector(arrow.direction),
        cell,
      );

      // Shadow pass.
      canvas.save();
      canvas.translate(kArrowShadowOffset.dx, kArrowShadowOffset.dy);
      paint.color = kArrowShadowColor.withValues(
        alpha: kArrowShadowColor.a * opacity,
      );
      canvas.drawPath(body, paint);
      canvas.drawPath(head, paint);
      canvas.restore();

      // Color pass.
      final color = colorOf(arrow.id);
      paint.color = color.withValues(alpha: color.a * opacity);
      canvas.drawPath(body, paint);
      canvas.drawPath(head, paint);

      // Rotation indicator for switchable arrows.
      if (arrow.isSwitchable) {
        final (tr, tc) = rc(arrow.tailNode);
        final tailCenter = cellCenter(tr, tc, cell);

        final indicatorPaint = Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.9 * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        canvas.drawCircle(tailCenter, cell * 0.13, indicatorPaint);

        // Small curved arc to suggest rotation.
        final arcRect = Rect.fromCircle(center: tailCenter, radius: cell * 0.09);
        canvas.drawArc(arcRect, -0.5, 1.8, false, indicatorPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ArrowsLayerPainter old) =>
      old.cell != cell ||
      old.opacity != opacity ||
      !listEquals(old.arrows, arrows);
}
