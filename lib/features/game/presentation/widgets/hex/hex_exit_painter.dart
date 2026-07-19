import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../../domain/entities/arrow_entity.dart';
import '../painting/arrow_geometry.dart'
    show buildChevron, kArrowShadowColor, kArrowShadowOffset, strokeWidthFor;
import 'hex_geometry.dart';

/// Paints one arrow sliding out of a hexagonal board "snake" style: a
/// fixed-length window of stroke advances along the full exit path (body
/// polyline continued straight past the edge) — the hex sibling of
/// [ArrowExitPainter].
class HexArrowExitPainter extends CustomPainter {
  HexArrowExitPainter({
    required this.arrow,
    required this.color,
    required this.hexSize,
    required this.radius,
    required this.origin,
    required this.progress,
  });

  final ArrowEntity arrow;
  final Color color;
  final double hexSize;
  final int radius;
  final Offset origin;

  /// 0 → fully on-board (window == body), 1 → fully gone.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final full = buildExitPath(arrow, hexSize, radius).shift(origin);
    final metrics = full.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;

    final bodyMetrics = buildBodyPath(arrow, hexSize).computeMetrics().toList();
    final bodyLen = bodyMetrics.isEmpty ? 0.0 : bodyMetrics.first.length;

    final start = progress * metric.length;
    if (start >= metric.length) return; // fully exited
    final end = math.min(start + bodyLen, metric.length);
    final window = metric.extractPath(start, end);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidthFor(hexSize)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final tan = metric.getTangentForOffset(math.min(end, metric.length - 0.01));
    Path? head;
    if (tan != null) {
      head = buildChevron(tan.position, tan.vector, hexSize);
    }

    canvas.save();
    canvas.translate(kArrowShadowOffset.dx, kArrowShadowOffset.dy);
    paint.color = kArrowShadowColor;
    canvas.drawPath(window, paint);
    if (head != null) canvas.drawPath(head, paint);
    canvas.restore();

    paint.color = color;
    canvas.drawPath(window, paint);
    if (head != null) canvas.drawPath(head, paint);
  }

  @override
  bool shouldRepaint(covariant HexArrowExitPainter old) =>
      old.progress != progress ||
      old.hexSize != hexSize ||
      old.color != color ||
      old.origin != origin;
}
