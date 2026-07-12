import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../../domain/entities/arrow_entity.dart';
import 'arrow_geometry.dart';

/// Draws every live arrow on the board in one pass as a thin stroked polyline
/// (tail→head) with a V arrowhead and a flat drop shadow, matching the design.
class ArrowsLayerPainter extends CustomPainter {
  ArrowsLayerPainter({
    required this.arrows,
    required this.colorOf,
    required this.cell,
  });

  final List<ArrowEntity> arrows;
  final Color Function(String id) colorOf;
  final double cell;

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
      paint.color = kArrowShadowColor;
      canvas.drawPath(body, paint);
      canvas.drawPath(head, paint);
      canvas.restore();

      // Color pass.
      paint.color = colorOf(arrow.id);
      canvas.drawPath(body, paint);
      canvas.drawPath(head, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ArrowsLayerPainter old) =>
      old.cell != cell || !listEquals(old.arrows, arrows);
}
