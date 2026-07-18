import 'package:flutter/rendering.dart';

/// Paints a board's dark backdrop with a subtle dotted pattern, matching the
/// design's `rgba(0,0,0,0.16)` fill + dotted `rgba(255,248,238,0.13)` pattern
/// (36px spacing at the design's reference scale).
///
/// Shared by [BoardGridWidget] (2D) and the 3D layer stack, so every board
/// surface — regardless of how many Z-layers sit above it — looks identical.
class BoardSurfacePainter extends CustomPainter {
  const BoardSurfacePainter(this.cell);

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
  bool shouldRepaint(covariant BoardSurfacePainter oldDelegate) =>
      oldDelegate.cell != cell;
}
