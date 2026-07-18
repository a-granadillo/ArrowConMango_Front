import 'package:equatable/equatable.dart';

/// Sealed class representing the dimensions and structure of a game board.
sealed class BoardGeometry extends Equatable {
  const BoardGeometry();
}

/// Concrete subclass representing 2D board geometry (rows, cols).
class BoardGeometry2D extends BoardGeometry {
  final int rows;
  final int cols;

  const BoardGeometry2D({
    required this.rows,
    required this.cols,
  })  : assert(rows > 0, 'rows must be greater than 0'),
        assert(cols > 0, 'cols must be greater than 0');

  @override
  List<Object?> get props => [rows, cols];

  @override
  String toString() => 'BoardGeometry2D(rows: $rows, cols: $cols)';
}

/// Concrete subclass representing 3D board geometry (rows, cols, depth).
class BoardGeometry3D extends BoardGeometry {
  final int rows;
  final int cols;
  final int depth;

  const BoardGeometry3D({
    required this.rows,
    required this.cols,
    required this.depth,
  })  : assert(rows > 0, 'rows must be greater than 0'),
        assert(cols > 0, 'cols must be greater than 0'),
        assert(depth > 0, 'depth must be greater than 0');

  @override
  List<Object?> get props => [rows, cols, depth];

  @override
  String toString() => 'BoardGeometry3D(rows: $rows, cols: $cols, depth: $depth)';
}

/// Concrete subclass representing a hexagonal board: a hexagon-shaped
/// arrangement of pointy-top hex cells with the given [radius], addressed
/// with axial coordinates (see [HexDirection], `HexNodeId`).
///
/// A cell at axial (q, r) belongs to the board when
/// `max(|q|, |r|, |q + r|) <= radius`, so `radius` alone fully determines
/// the board's shape and size (a radius-N hexagon has `3*N*(N+1) + 1` cells).
class BoardGeometryHex extends BoardGeometry {
  final int radius;

  const BoardGeometryHex({required this.radius})
      : assert(radius > 0, 'radius must be greater than 0');

  @override
  List<Object?> get props => [radius];

  @override
  String toString() => 'BoardGeometryHex(radius: $radius)';
}
