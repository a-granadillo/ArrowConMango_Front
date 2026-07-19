import 'dart:math' as math;
import 'dart:ui';

import '../../../domain/entities/arrow_entity.dart';
import '../../../domain/entities/direction.dart';
import '../../../domain/entities/hex_direction.dart';
import '../../../domain/entities/node_id.dart';

/// Pure geometry helpers for rendering a hexagonal (pointy-top) board and its
/// arrows. Mirrors `arrow_geometry.dart`'s 2D helpers, but axial (q, r)
/// coordinates need trigonometric pixel conversion instead of a simple
/// `(col, row) * cell` grid — everything here is a pure function, so it's
/// trivially unit-testable without a Flutter widget/render tree.
const double _sqrt3 = 1.7320508075688772;

/// Parses a `HexNodeId` key `"q_r"` into `(q, r)`.
(int, int) qr(NodeId node) {
  final parts = node.key.split('_');
  return (int.parse(parts[0]), int.parse(parts[1]));
}

/// Pixel center of a pointy-top hex at axial (q, r), for a hex of
/// circumradius [size], relative to the board's own (0, 0) origin — callers
/// translate by the board center themselves (see [HexBoardWidget]).
Offset axialToPixel(int q, int r, double size) {
  final x = size * (_sqrt3 * q + _sqrt3 / 2 * r);
  final y = size * (1.5 * r);
  return Offset(x, y);
}

/// Inverse of [axialToPixel]: the axial (q, r) of the hex whose cell
/// contains pixel [point] (relative to the board's origin), for hexes of
/// circumradius [size]. Used for tap hit-testing.
(int, int) pixelToAxial(Offset point, double size) {
  final q = (_sqrt3 / 3 * point.dx - 1 / 3 * point.dy) / size;
  final r = (2 / 3 * point.dy) / size;
  return _roundAxial(q, r);
}

/// Rounds fractional axial coordinates to the nearest integer hex, via cube
/// coordinates (the standard technique — direct rounding of q/r
/// independently can land in the wrong cell near edges).
(int, int) _roundAxial(double qf, double rf) {
  final sf = -qf - rf;
  var q = qf.round();
  var r = rf.round();
  var s = sf.round();

  final qDiff = (q - qf).abs();
  final rDiff = (r - rf).abs();
  final sDiff = (s - sf).abs();

  if (qDiff > rDiff && qDiff > sDiff) {
    q = -r - s;
  } else if (rDiff > sDiff) {
    r = -q - s;
  } else {
    s = -q - r;
  }
  return (q, r);
}

/// The six corner points of a pointy-top hex centered at [center], with
/// circumradius [size].
List<Offset> hexCorners(Offset center, double size) {
  return [
    for (var i = 0; i < 6; i++)
      center +
          Offset(
            size * math.cos((60 * i - 30) * math.pi / 180),
            size * math.sin((60 * i - 30) * math.pi / 180),
          ),
  ];
}

/// The axial (dq, dr) step for a hex [direction], matching the vectors used
/// by `HexGraph` (pointy-top layout).
(int, int) axialVector(HexDirection direction) => switch (direction) {
      HexDirection.n => (0, -1),
      HexDirection.ne => (1, -1),
      HexDirection.se => (1, 0),
      HexDirection.s => (0, 1),
      HexDirection.sw => (-1, 1),
      HexDirection.nw => (-1, 0),
    };

/// Unit vector (in screen coords: +y is down) for a hex [direction],
/// matching the axial vectors used by `HexGraph` (pointy-top layout).
Offset unitVector(Direction direction) {
  if (direction is! HexDirection) return Offset.zero;
  final (dq, dr) = axialVector(direction);
  final v = axialToPixel(dq, dr, 1);
  final length = v.distance;
  return length == 0 ? Offset.zero : v / length;
}

/// Whether axial (q, r) lies within a hexagon-shaped board of the given
/// [radius] (same rule as `HexBoardGeometry`/`HexGraph`).
bool _inBounds(int q, int r, int radius) {
  final s = -q - r;
  final maxAbs = math.max(q.abs(), math.max(r.abs(), s.abs()));
  return maxAbs <= radius;
}

/// Number of hex steps from the arrow's head to just past a board of
/// [radius] (in-board steps + 1 margin cell so the head clears the frame) —
/// the hex sibling of the 2D `exitCells`.
int exitCells(ArrowEntity arrow, int radius) {
  if (arrow.direction is! HexDirection) return 1;
  final (dq, dr) = axialVector(arrow.direction as HexDirection);
  final (hq, hr) = qr(arrow.headNode);
  var q = hq + dq, r = hr + dr, n = 0;
  while (_inBounds(q, r, radius)) {
    n++;
    q += dq;
    r += dr;
  }
  return n + 1;
}

/// The polyline through the arrow's occupied cell centers, tail→head.
///
/// Single-cell arrows would yield a degenerate (empty-metrics) path, so a
/// short stub is emitted behind the head instead. Always exactly one
/// contour, mirroring the 2D `buildBodyPath`.
Path buildBodyPath(ArrowEntity arrow, double size) {
  final path = Path();
  final nodes = arrow.occupiedNodes;
  if (nodes.isEmpty) return path;

  if (nodes.length == 1) {
    final (q, r) = qr(nodes.first);
    final center = axialToPixel(q, r, size);
    final back = unitVector(arrow.direction) * (size * 0.15);
    path
      ..moveTo(center.dx - back.dx, center.dy - back.dy)
      ..lineTo(center.dx, center.dy);
    return path;
  }

  final (q0, r0) = qr(nodes.first);
  final start = axialToPixel(q0, r0, size);
  path.moveTo(start.dx, start.dy);
  for (var i = 1; i < nodes.length; i++) {
    final (q, r) = qr(nodes[i]);
    final p = axialToPixel(q, r, size);
    path.lineTo(p.dx, p.dy);
  }
  return path;
}

/// The full snake exit path: the body polyline continued by a straight
/// segment from the head out past a board of [radius]. Exactly one contour
/// (one moveTo) so [Path.computeMetrics] yields a single, extractable
/// metric — the hex sibling of the 2D `buildExitPath`.
Path buildExitPath(ArrowEntity arrow, double size, int radius) {
  final path = buildBodyPath(arrow, size);
  final (hq, hr) = qr(arrow.headNode);
  final head = axialToPixel(hq, hr, size);
  final v = unitVector(arrow.direction);
  // Center-to-center distance between axially-adjacent pointy-top hexes.
  final stepDistance = size * _sqrt3;
  final end = head + v * (exitCells(arrow, radius) * stepDistance);
  path.lineTo(end.dx, end.dy);
  return path;
}
