import '../../domain/entities/cardinal_direction.dart';
import '../../domain/entities/direction.dart';
import '../../domain/services/graph.dart';
import 'grid_2d_topology.dart';

/// Concrete graph implementation for 2D grids.
///
/// Each cell (row, col) is a node. Edges connect adjacent cells
/// (up, down, left, right) with [CardinalDirection] labels.
///
/// This is the ONLY class that knows about (row, col) arithmetic.
/// The domain layer interacts through the [Graph] interface.
class GridGraph implements Graph<Grid2DNodeId> {
  final int rows;
  final int cols;

  /// Precomputed adjacency list for O(1) neighbor lookups.
  /// Key: node key (e.g., "2_3"), Value: map of direction -> neighbor node.
  final Map<String, Map<Direction, Grid2DNodeId>> _adjacency;

  /// Precomputed boundary information.
  /// Key: node key, Value: set of directions that exit the graph.
  final Map<String, Set<Direction>> _boundaries;

  GridGraph._({
    required this.rows,
    required this.cols,
    required this._adjacency,
    required this._boundaries,
  });

  factory GridGraph.build({required int rows, required int cols}) {
    final adjacency = <String, Map<Direction, Grid2DNodeId>>{};
    final boundaries = <String, Set<Direction>>{};

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final node = Grid2DNodeId(row: r, col: c);
        final neighbors = <Direction, Grid2DNodeId>{};
        final boundaryDirs = <Direction>{};

        for (final dir in CardinalDirection.values) {
          final neighbor = _computeNeighbor(r, c, dir);
          if (_isValid(neighbor, rows, cols)) {
            neighbors[dir] = neighbor;
          } else {
            boundaryDirs.add(dir);
          }
        }

        adjacency[node.key] = neighbors;
        boundaries[node.key] = boundaryDirs;
      }
    }

    return GridGraph._(
      rows: rows,
      cols: cols,
      adjacency: adjacency,
      boundaries: boundaries,
    );
  }

  static Grid2DNodeId _computeNeighbor(
    int row,
    int col,
    CardinalDirection direction,
  ) {
    switch (direction) {
      case CardinalDirection.up:
        return Grid2DNodeId(row: row - 1, col: col);
      case CardinalDirection.down:
        return Grid2DNodeId(row: row + 1, col: col);
      case CardinalDirection.left:
        return Grid2DNodeId(row: row, col: col - 1);
      case CardinalDirection.right:
        return Grid2DNodeId(row: row, col: col + 1);
    }
  }

  static bool _isValid(Grid2DNodeId node, int rows, int cols) {
    return node.row >= 0 && node.row < rows && node.col >= 0 && node.col < cols;
  }

  @override
  int get nodeCount => rows * cols;

  @override
  Iterable<Grid2DNodeId> get nodes sync* {
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        yield Grid2DNodeId(row: r, col: c);
      }
    }
  }

  @override
  Grid2DNodeId? getNeighbor(Grid2DNodeId node, Direction direction) {
    final neighbors = _adjacency[node.key];
    return neighbors?[direction];
  }

  @override
  List<Direction> getValidDirections(Grid2DNodeId node) {
    final neighbors = _adjacency[node.key];
    if (neighbors == null) return [];
    return neighbors.keys.toList();
  }

  @override
  Map<Direction, Grid2DNodeId> getNeighbors(Grid2DNodeId node) {
    return _adjacency[node.key] ?? {};
  }

  @override
  bool containsNode(Grid2DNodeId node) {
    return _adjacency.containsKey(node.key);
  }

  @override
  bool isBoundary(Grid2DNodeId node, Direction direction) {
    final bounds = _boundaries[node.key];
    return bounds?.contains(direction) ?? false;
  }

  @override
  List<Grid2DNodeId> getTrajectory(Grid2DNodeId start, Direction direction) {
    final cardinal = _castDirection(direction);
    final result = <Grid2DNodeId>[];
    var current = start;

    while (true) {
      final next = getNeighbor(current, cardinal);
      if (next == null) break;
      result.add(next);
      current = next;
    }

    return result;
  }

  @override
  List<Grid2DNodeId> getShiftedNodes({
    required Grid2DNodeId headPosition,
    required Direction direction,
    required int length,
    required int steps,
  }) {
    final cardinal = _castDirection(direction);
    final opposite = _opposite(cardinal);

    // Move head forward by steps
    var newHead = headPosition;
    for (var i = 0; i < steps; i++) {
      final next = getNeighbor(newHead, cardinal);
      if (next == null) break;
      newHead = next;
    }

    // Build the shifted path backwards from new head
    final nodesReversed = <Grid2DNodeId>[];
    var current = newHead;
    nodesReversed.add(current);

    for (var i = 1; i < length; i++) {
      final prev = getNeighbor(current, opposite);
      if (prev == null) break;
      nodesReversed.add(prev);
      current = prev;
    }

    return nodesReversed.reversed.toList();
  }

  CardinalDirection _castDirection(Direction direction) {
    if (direction is! CardinalDirection) {
      throw ArgumentError(
        'Expected CardinalDirection, got ${direction.runtimeType}',
      );
    }
    return direction;
  }

  CardinalDirection _opposite(CardinalDirection direction) {
    switch (direction) {
      case CardinalDirection.up:
        return CardinalDirection.down;
      case CardinalDirection.down:
        return CardinalDirection.up;
      case CardinalDirection.left:
        return CardinalDirection.right;
      case CardinalDirection.right:
        return CardinalDirection.left;
    }
  }
}

/// Builder for [GridGraph].
class GridGraphBuilder implements GraphBuilder<Grid2DNodeId> {
  final int rows;
  final int cols;

  const GridGraphBuilder({required this.rows, required this.cols});

  @override
  Graph<Grid2DNodeId> build() {
    return GridGraph.build(rows: rows, cols: cols);
  }
}
