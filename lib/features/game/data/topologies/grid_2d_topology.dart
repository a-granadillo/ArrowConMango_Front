import '../../domain/entities/cardinal_direction.dart';
import '../../domain/entities/direction.dart';
import '../../domain/entities/node_id.dart';
import '../../domain/services/topology.dart';
import 'grid_graph.dart';

/// Concrete 2D grid topology (Layer 4 — Infrastructure).
///
/// Internally uses an explicit [GridGraph] to represent the spatial structure.
/// This is the ONLY class that knows about (row, col) coordinates.
/// The domain layer never sees this class — it interacts through
/// the [Topology] interface.
///
/// The graph-based approach allows:
/// - O(1) neighbor lookups via precomputed adjacency lists
/// - Clear separation between graph structure and spatial queries
/// - Future extension to non-rectangular topologies (hexagonal, irregular)
class Grid2DTopology implements Topology {
  final int rows;
  final int cols;

  /// The underlying graph structure that represents the grid topology.
  final GridGraph _graph;

  Grid2DTopology({required this.rows, required this.cols})
      : _graph = GridGraph.build(rows: rows, cols: cols);

  @override
  int get nodeCount => _graph.nodeCount;

  @override
  List<Direction> get supportedDirections => CardinalDirection.values;

  @override
  List<NodeId> getTrajectory(NodeId start, Direction direction) {
    final gridStart = _castNode(start);
    return _graph.getTrajectory(gridStart, direction);
  }

  @override
  List<NodeId> getShiftedNodes({
    required NodeId headPosition,
    required Direction direction,
    required int length,
    required int steps,
  }) {
    final gridHead = _castNode(headPosition);
    return _graph.getShiftedNodes(
      headPosition: gridHead,
      direction: direction,
      length: length,
      steps: steps,
    );
  }

  @override
  NodeId? getNeighbor(NodeId node, Direction direction) {
    final gridNode = _castNode(node);
    return _graph.getNeighbor(gridNode, direction);
  }

  @override
  List<Direction> getValidDirections(NodeId node) {
    final gridNode = _castNode(node);
    return _graph.getValidDirections(gridNode);
  }

  @override
  bool contains(NodeId node) {
    final gridNode = _castNode(node);
    return _graph.containsNode(gridNode);
  }

  @override
  bool isExitBoundary(NodeId node, Direction direction) {
    final gridNode = _castNode(node);
    return _graph.isBoundary(gridNode, direction);
  }

  Grid2DNodeId _castNode(NodeId node) {
    if (node is! Grid2DNodeId) {
      throw ArgumentError(
        'Expected Grid2DNodeId, got ${node.runtimeType}',
      );
    }
    return node;
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
