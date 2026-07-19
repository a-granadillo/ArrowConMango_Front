import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../../domain/entities/arrow_entity.dart';
import '../painting/arrow_geometry.dart' show strokeWidthFor;
import 'hex_geometry.dart';

/// Paints a brief red "impact flash" over an arrow's body on a hexagonal
/// board — used when two arrows collide (one's exit path is blocked by the
/// other). The hex sibling of [ArrowImpactPainter].
class HexArrowImpactPainter extends CustomPainter {
  HexArrowImpactPainter({
    required this.arrow,
    required this.hexSize,
    required this.origin,
    required this.progress,
  });

  final ArrowEntity arrow;
  final double hexSize;
  final Offset origin;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = buildBodyPath(arrow, hexSize).shift(origin);
    if (path.computeMetrics().isEmpty) return;

    // Fast fade-in, slower fade-out: peaks around progress ~0.25.
    final alpha = progress < 0.25
        ? progress / 0.25
        : 1 - ((progress - 0.25) / 0.75);

    // Small perpendicular jitter so the stroke reads as a shake, not a glow.
    final jitter = math.sin(progress * math.pi * 6) * hexSize * 0.06;

    final paint = Paint()
      ..color = const Color(0xFFE53935).withValues(alpha: alpha.clamp(0, 1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidthFor(hexSize) * 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.save();
    canvas.translate(jitter, 0);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HexArrowImpactPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.arrow != arrow ||
      oldDelegate.hexSize != hexSize ||
      oldDelegate.origin != origin;
}
