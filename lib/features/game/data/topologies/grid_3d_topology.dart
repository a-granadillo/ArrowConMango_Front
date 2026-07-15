import '../../domain/entities/direction.dart';
import '../../domain/entities/node_id.dart';
import '../../domain/entities/spatial_direction.dart';
import '../../domain/services/topology.dart';
import 'grid_3d_graph.dart';

/// Concrete 3D grid topology (Layer 4 — Infrastructure).
///
/// Internally uses an explicit [Grid3DGraph] to represent the spatial
/// structure. This is the ONLY class that knows about (x, y, z) coordinates.
/// The domain layer never sees this class — it interacts through
/// the [Topology] interface.
///
/// Coordinate convention: x = column, y = row, z = depth (layer).
class Grid3DTopology implements Topology {
  final int width;
  final int height;
  final int depth;

  /// The underlying graph structure that represents the 3D grid topology.
  final Grid3DGraph _graph;

  Grid3DTopology({
    required this.width,
    required this.height,
    required this.depth,
  }) : _graph = Grid3DGraph.build(width: width, height: height, depth: depth);

  @override
  int get nodeCount => _graph.nodeCount;

  @override
  List<Direction> get supportedDirections => SpatialDirection.values;

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

  Cube3DNodeId _castNode(NodeId node) {
    if (node is! Cube3DNodeId) {
      throw ArgumentError(
        'Expected Cube3DNodeId, got ${node.runtimeType}',
      );
    }
    return node;
  }
}

/// Concrete NodeId for 3D grids (Layer 4).
class Cube3DNodeId extends NodeId {
  final int x;
  final int y;
  final int z;

  const Cube3DNodeId({required this.x, required this.y, required this.z});

  @override
  String get key => '${x}_${y}_$z';

  @override
  List<Object?> get props => [x, y, z];
}
