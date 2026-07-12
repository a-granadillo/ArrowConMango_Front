import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../../domain/entities/arrow_entity.dart';
import 'arrow_geometry.dart';

/// Paints one arrow sliding out of the board "snake" style: a fixed-length
/// window of stroke advances along the full exit path (body polyline continued
/// straight past the edge), so the arrow follows its own bends and then leaves.
///
/// Mirrors the design's SVG `stroke-dashoffset` exit animation.
class ArrowExitPainter extends CustomPainter {
  ArrowExitPainter({
    required this.arrow,
    required this.color,
    required this.cell,
    required this.rows,
    required this.cols,
    required this.progress,
  });

  final ArrowEntity arrow;
  final Color color;
  final double cell;
  final int rows;
  final int cols;

  /// 0 → fully on-board (window == body), 1 → fully gone.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final full = buildExitPath(arrow, cell, rows, cols);
    final metrics = full.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;

    final bodyMetrics = buildBodyPath(arrow, cell).computeMetrics().toList();
    final bodyLen = bodyMetrics.isEmpty ? 0.0 : bodyMetrics.first.length;

    final start = progress * metric.length;
    if (start >= metric.length) return; // fully exited
    final end = math.min(start + bodyLen, metric.length);
    final window = metric.extractPath(start, end);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidthFor(cell)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Arrowhead sits at the leading edge of the window, along its tangent.
    final tan = metric.getTangentForOffset(math.min(end, metric.length - 0.01));
    Path? head;
    if (tan != null) {
      head = buildChevron(tan.position, tan.vector, cell);
    }

    // Shadow pass.
    canvas.save();
    canvas.translate(kArrowShadowOffset.dx, kArrowShadowOffset.dy);
    paint.color = kArrowShadowColor;
    canvas.drawPath(window, paint);
    if (head != null) canvas.drawPath(head, paint);
    canvas.restore();

    // Color pass.
    paint.color = color;
    canvas.drawPath(window, paint);
    if (head != null) canvas.drawPath(head, paint);
  }

  @override
  bool shouldRepaint(covariant ArrowExitPainter old) =>
      old.progress != progress || old.cell != cell || old.color != color;
}
