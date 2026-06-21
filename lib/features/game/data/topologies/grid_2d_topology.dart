import '../../domain/entities/direction.dart';
import '../../domain/entities/node_id.dart';
import '../../domain/services/topology.dart';

/// Concrete 2D grid topology (Layer 4 — Infrastructure).
///
/// This is the ONLY class that knows about (row, col) arithmetic.
/// The domain layer never sees this class — it interacts through
/// the [Topology] interface.
class Grid2DTopology implements Topology {
  final int rows;
  final int cols;

  const Grid2DTopology({required this.rows, required this.cols});

  @override
  int get nodeCount => rows * cols;

  @override
  List<Direction> get supportedDirections => CardinalDirection.values;

  @override
  List<NodeId> getTrajectory(NodeId start, Direction direction) {
    final gridStart = _castNode(start);
    final cardinal = _castDirection(direction);

    final result = <NodeId>[];
    var current = gridStart;

    while (true) {
      final next = _moveNode(current, cardinal, 1);
      if (!contains(next)) break;
      result.add(next);
      current = next;
    }

    return result;
  }

  @override
  List<NodeId> getShiftedNodes({
    required NodeId headPosition,
    required Direction direction,
    required int length,
    required int steps,
  }) {
    final gridHead = _castNode(headPosition);
    final cardinal = _castDirection(direction);

    final newHead = _moveNode(gridHead, cardinal, steps);
    final opposite = _opposite(cardinal);

    final nodesReversed = <NodeId>[];
    var current = newHead;
    for (var i = 0; i < length; i++) {
      nodesReversed.add(current);
      if (i < length - 1) {
        current = _moveNode(current, opposite, 1);
      }
    }

    return nodesReversed.reversed.toList();
  }

  @override
  NodeId? getNeighbor(NodeId node, Direction direction) {
    final gridNode = _castNode(node);
    final cardinal = _castDirection(direction);

    final moved = _moveNode(gridNode, cardinal, 1);
    return contains(moved) ? moved : null;
  }

  @override
  List<Direction> getValidDirections(NodeId node) {
    final directions = <Direction>[];
    for (final direction in CardinalDirection.values) {
      if (getNeighbor(node, direction) != null) {
        directions.add(direction);
      }
    }
    return directions;
  }

  @override
  bool contains(NodeId node) {
    final gridNode = _castNode(node);
    return gridNode.row >= 0 &&
        gridNode.row < rows &&
        gridNode.col >= 0 &&
        gridNode.col < cols;
  }

  @override
  bool isExitBoundary(NodeId node, Direction direction) {
    return getNeighbor(node, direction) == null;
  }

  Grid2DNodeId _moveNode(
    Grid2DNodeId node,
    CardinalDirection direction,
    int steps,
  ) {
    final oneStep = _move(node.row, node.col, direction);
    final dRow = oneStep.row - node.row;
    final dCol = oneStep.col - node.col;

    return Grid2DNodeId(
      row: node.row + dRow * steps,
      col: node.col + dCol * steps,
    );
  }

  ({int row, int col}) _move(int row, int col, CardinalDirection direction) {
    switch (direction) {
      case CardinalDirection.up:
        return (row: row - 1, col: col);
      case CardinalDirection.down:
        return (row: row + 1, col: col);
      case CardinalDirection.left:
        return (row: row, col: col - 1);
      case CardinalDirection.right:
        return (row: row, col: col + 1);
    }
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

  Grid2DNodeId _castNode(NodeId node) {
    if (node is! Grid2DNodeId) {
      throw ArgumentError(
        'Expected Grid2DNodeId, got ${node.runtimeType}',
      );
    }
    return node;
  }

  CardinalDirection _castDirection(Direction direction) {
    if (direction is! CardinalDirection) {
      throw ArgumentError(
        'Expected CardinalDirection, got ${direction.runtimeType}',
      );
    }
    return direction;
  }
}

/// Concrete NodeId for 2D grids (Layer 4).
class Grid2DNodeId extends NodeId {
  final int row;
  final int col;

  const Grid2DNodeId({required this.row, required this.col});

  @override
  String get key => '${row}_$col';

  @override
  List<Object?> get props => [row, col];
}

/// Concrete Direction for 4-cardinal grids (Layer 4).
enum CardinalDirection implements Direction {
  up,
  right,
  down,
  left;

  @override
  String get label => name;
}
