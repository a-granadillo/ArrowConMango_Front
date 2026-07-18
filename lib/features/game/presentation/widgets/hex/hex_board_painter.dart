import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../../domain/entities/arrow_entity.dart';
import '../painting/arrow_geometry.dart'
    show buildChevron, kArrowShadowColor, kArrowShadowOffset, strokeWidthFor;
import 'hex_geometry.dart';

/// Paints the hexagonal board's dark backdrop plus an outline for every cell
/// of the given [radius], centered at [origin] (the board's own (0,0) in
/// canvas pixels — see [HexBoardWidget]). Mirrors [BoardSurfacePainter]'s
/// look (dark fill, subtle light strokes) adapted to a hex grid.
class HexSurfacePainter extends CustomPainter {
  const HexSurfacePainter({
    required this.radius,
    required this.hexSize,
    required this.origin,
  });

  final int radius;
  final double hexSize;
  final Offset origin;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      Paint()..color = const Color(0x29000000),
    );

    final outlinePaint = Paint()
      ..color = const Color(0x21FFF8EE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var q = -radius; q <= radius; q++) {
      final rMin = _max(-radius, -q - radius);
      final rMax = _min(radius, -q + radius);
      for (var r = rMin; r <= rMax; r++) {
        final center = origin + axialToPixel(q, r, hexSize);
        final corners = hexCorners(center, hexSize * 0.94);
        final path = Path()..addPolygon(corners, true);
        canvas.drawPath(path, outlinePaint);
      }
    }
  }

  static int _max(int a, int b) => a > b ? a : b;
  static int _min(int a, int b) => a < b ? a : b;

  @override
  bool shouldRepaint(covariant HexSurfacePainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.hexSize != hexSize ||
      oldDelegate.origin != origin;
}

/// Draws every live arrow on a hexagonal board in one pass, as a thin
/// stroked polyline (tail→head) with a V arrowhead and a flat drop shadow —
/// the hex-board sibling of [ArrowsLayerPainter], using axial pixel centers
/// instead of grid `(row, col)` ones.
class HexArrowsLayerPainter extends CustomPainter {
  HexArrowsLayerPainter({
    required this.arrows,
    required this.colorOf,
    required this.hexSize,
    required this.origin,
    this.opacity = 1.0,
  });

  final List<ArrowEntity> arrows;
  final Color Function(String id) colorOf;
  final double hexSize;
  final Offset origin;

  /// Scales both the shadow and color passes uniformly (1.0 = fully
  /// opaque) — used by the creative-mode editor to render its drag preview
  /// as a translucent overlay, mirroring [ArrowsLayerPainter]'s `opacity`.
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidthFor(hexSize)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final arrow in arrows) {
      final body = buildBodyPath(arrow, hexSize).shift(origin);
      final (hq, hr) = qr(arrow.headNode);
      final head = buildChevron(
        origin + axialToPixel(hq, hr, hexSize),
        unitVector(arrow.direction),
        hexSize,
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

      if (arrow.isSwitchable) {
        final (tq, tr) = qr(arrow.tailNode);
        final tailCenter = origin + axialToPixel(tq, tr, hexSize);

        final indicatorPaint = Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.9 * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        canvas.drawCircle(tailCenter, hexSize * 0.13, indicatorPaint);
        final arcRect =
            Rect.fromCircle(center: tailCenter, radius: hexSize * 0.09);
        canvas.drawArc(arcRect, -0.5, 1.8, false, indicatorPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HexArrowsLayerPainter old) =>
      old.hexSize != hexSize ||
      old.origin != origin ||
      old.opacity != opacity ||
      !listEquals(old.arrows, arrows);
}
