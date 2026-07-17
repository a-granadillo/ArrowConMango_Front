import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../../domain/entities/arrow_entity.dart';
import 'arrow_geometry.dart';

/// Paints a brief red "impact flash" over an arrow's body — used when two
/// arrows collide (one's exit path is blocked by the other).
///
/// [progress] runs 0→1 over the animation's lifetime; the flash pulses once
/// (fades in fast, out slower) and its stroke jitters slightly to read as a
/// bump rather than a static highlight.
class ArrowImpactPainter extends CustomPainter {
  ArrowImpactPainter({
    required this.arrow,
    required this.cell,
    required this.progress,
  });

  final ArrowEntity arrow;
  final double cell;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = buildBodyPath(arrow, cell);
    if (path.getBounds().isEmpty) return;

    // Fast fade-in, slower fade-out: peaks around progress ~0.25.
    final alpha = progress < 0.25
        ? progress / 0.25
        : 1 - ((progress - 0.25) / 0.75);

    // Small perpendicular jitter so the stroke reads as a shake, not a glow.
    final jitter = math.sin(progress * math.pi * 6) * cell * 0.06;

    final paint = Paint()
      ..color = const Color(0xFFE53935).withValues(alpha: alpha.clamp(0, 1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidthFor(cell) * 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.save();
    canvas.translate(jitter, 0);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ArrowImpactPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.arrow != arrow ||
      oldDelegate.cell != cell;
}
