import '../../domain/entities/direction.dart';
import '../../domain/entities/hex_direction.dart';
import '../../domain/entities/node_id.dart';
import '../../domain/services/topology.dart';
import 'hex_graph.dart';

/// Concrete hexagonal-board topology (Layer 4 — Infrastructure).
///
/// Internally uses an explicit [HexGraph] to represent the spatial
/// structure. This is the ONLY class that knows about (q, r) axial
/// coordinates. The domain layer never sees this class — it interacts
/// through the [Topology] interface.
class HexTopology implements Topology {
  final int radius;

  /// The underlying graph structure that represents the hex board topology.
  final HexGraph _graph;

  HexTopology({required this.radius}) : _graph = HexGraph.build(radius: radius);

  @override
  int get nodeCount => _graph.nodeCount;

  @override
  List<Direction> get supportedDirections => HexDirection.values;

  /// All node ids on this board, e.g. for level-generation code that needs
  /// to enumerate cells (not part of the [Topology] contract — hexagonal
  /// boards have no rows/cols to iterate the way a rectangular grid does).
  List<HexNodeId> get allNodes => _graph.nodes.toList();

  @override
  List<NodeId> getTrajectory(NodeId start, Direction direction) {
    final hexStart = _castNode(start);
    return _graph.getTrajectory(hexStart, direction);
  }

  @override
  List<NodeId> getShiftedNodes({
    required NodeId headPosition,
    required Direction direction,
    required int length,
    required int steps,
  }) {
    final hexHead = _castNode(headPosition);
    return _graph.getShiftedNodes(
      headPosition: hexHead,
      direction: direction,
      length: length,
      steps: steps,
    );
  }

  @override
  NodeId? getNeighbor(NodeId node, Direction direction) {
    final hexNode = _castNode(node);
    return _graph.getNeighbor(hexNode, direction);
  }

  @override
  List<Direction> getValidDirections(NodeId node) {
    final hexNode = _castNode(node);
    return _graph.getValidDirections(hexNode);
  }

  @override
  bool contains(NodeId node) {
    final hexNode = _castNode(node);
    return _graph.containsNode(hexNode);
  }

  @override
  bool isExitBoundary(NodeId node, Direction direction) {
    final hexNode = _castNode(node);
    return _graph.isBoundary(hexNode, direction);
  }

  HexNodeId _castNode(NodeId node) {
    if (node is! HexNodeId) {
      throw ArgumentError(
        'Expected HexNodeId, got ${node.runtimeType}',
      );
    }
    return node;
  }
}
