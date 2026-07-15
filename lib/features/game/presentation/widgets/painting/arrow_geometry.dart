import 'dart:ui';

import '../../../domain/entities/arrow_entity.dart';
import '../../../domain/entities/cardinal_direction.dart';
import '../../../domain/entities/direction.dart';
import '../../../domain/entities/node_id.dart';

/// Pure geometry helpers for rendering arrows as thin, snake-like strokes
/// (a polyline through the centers of the cells an arrow occupies plus a V
/// arrowhead), matching the reference design. No Flutter widget/state here so
/// everything is trivially unit-testable.

/// Stroke width relative to a cell (design SVG: stroke-width 13 on 36px cells).
double strokeWidthFor(double cell) => cell * 0.36;

/// The flat drop shadow the design uses: `drop-shadow(0 3px 0 rgba(0,0,0,.28))`.
const Offset kArrowShadowOffset = Offset(0, 3);
const Color kArrowShadowColor = Color(0x47000000);

/// Center point (in board pixels) of cell ([row], [col]) given [cell] size.
Offset cellCenter(int row, int col, double cell) =>
    Offset((col + 0.5) * cell, (row + 0.5) * cell);

/// Unit vector (in screen coords: +y is down) for a cardinal [direction].
Offset unitVector(Direction direction) => switch (direction) {
      CardinalDirection.up => const Offset(0, -1),
      CardinalDirection.down => const Offset(0, 1),
      CardinalDirection.left => const Offset(-1, 0),
      CardinalDirection.right => const Offset(1, 0),
      Direction() => Offset.zero,
    };

/// Parses a `Grid2DNodeId` key `"row_col"` into `(row, col)`.
(int, int) rc(NodeId node) {
  final parts = node.key.split('_');
  return (int.parse(parts[0]), int.parse(parts[1]));
}

/// The polyline through the arrow's occupied cell centers, tail→head.
///
/// Single-cell arrows would yield a degenerate (empty-metrics) path, so a short
/// stub is emitted behind the head instead. Always exactly one contour.
Path buildBodyPath(ArrowEntity arrow, double cell) {
  final path = Path();
  final nodes = arrow.occupiedNodes;
  if (nodes.isEmpty) return path;

  if (nodes.length == 1) {
    final (r, c) = rc(nodes.first);
    final center = cellCenter(r, c, cell);
    final back = unitVector(arrow.direction) * (cell * 0.15);
    path
      ..moveTo(center.dx - back.dx, center.dy - back.dy)
      ..lineTo(center.dx, center.dy);
    return path;
  }

  final (r0, c0) = rc(nodes.first);
  final start = cellCenter(r0, c0, cell);
  path.moveTo(start.dx, start.dy);
  for (var i = 1; i < nodes.length; i++) {
    final (r, c) = rc(nodes[i]);
    final p = cellCenter(r, c, cell);
    path.lineTo(p.dx, p.dy);
  }
  return path;
}

/// An open V arrowhead centered at [anchor], pointing along unit [dir].
Path buildChevron(Offset anchor, Offset dir, double cell) {
  final tip = anchor + dir * (cell * 0.10);
  final perp = Offset(-dir.dy, dir.dx);
  final arm = cell * 0.30;
  final back = -dir * (arm * 0.72);
  final wing1 = tip + back + perp * (arm * 0.72);
  final wing2 = tip + back - perp * (arm * 0.72);
  return Path()
    ..moveTo(wing1.dx, wing1.dy)
    ..lineTo(tip.dx, tip.dy)
    ..lineTo(wing2.dx, wing2.dy);
}

/// Number of cells from the head to just past the board edge along the arrow's
/// direction (in-board steps + 1 margin cell so the head clears the frame).
int exitCells(ArrowEntity arrow, int rows, int cols) {
  final (hr, hc) = rc(arrow.headNode);
  final v = unitVector(arrow.direction);
  final dr = v.dy.round();
  final dc = v.dx.round();
  var r = hr + dr, c = hc + dc, n = 0;
  while (r >= 0 && r < rows && c >= 0 && c < cols) {
    n++;
    r += dr;
    c += dc;
  }
  return n + 1;
}

/// The full snake exit path: the body polyline continued by a straight segment
/// from the head out past the board edge. Exactly one contour (one moveTo) so
/// [Path.computeMetrics] yields a single, extractable metric.
Path buildExitPath(ArrowEntity arrow, double cell, int rows, int cols) {
  final path = buildBodyPath(arrow, cell);
  final (hr, hc) = rc(arrow.headNode);
  final head = cellCenter(hr, hc, cell);
  final v = unitVector(arrow.direction);
  final end = head + v * (exitCells(arrow, rows, cols) * cell);
  path.lineTo(end.dx, end.dy);
  return path;
}
