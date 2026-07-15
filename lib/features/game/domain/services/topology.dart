import '../entities/direction.dart';
import '../entities/node_id.dart';

/// Computes linear trajectories through the space.
/// This is the PRIMARY contract for the exit-check mechanic.
abstract class TrajectoryProvider {
  /// Returns the ordered list of nodes from [start] (exclusive) to the
  /// boundary of the space (inclusive), traveling in [direction].
  ///
  /// The [start] node itself is NOT included in the result.
  /// The final element is the last valid node before exiting the space.
  ///
  /// Throws [ArgumentError] if [direction] is not valid for this topology.
  List<NodeId> getTrajectory(NodeId start, Direction direction);

  /// Returns the ordered list of nodes occupied by an arrow of [length]
  /// after it has slid [steps] forward from its current [headPosition].
  ///
  /// Used to compute the arrow's new occupied nodes after a partial slide.
  List<NodeId> getShiftedNodes({
    required NodeId headPosition,
    required Direction direction,
    required int length,
    required int steps,
  });
}

/// Provides adjacency queries (single-step neighbors).
abstract class AdjacencyProvider {
  /// Returns the immediate neighbor of [node] in [direction],
  /// or `null` if [node] is at the boundary in that direction.
  NodeId? getNeighbor(NodeId node, Direction direction);

  /// Returns all valid directions from [node] (i.e., directions
  /// that lead to at least one adjacent node within bounds).
  List<Direction> getValidDirections(NodeId node);
}

/// Provides boundary and containment queries.
abstract class BoundaryProvider {
  /// Whether [node] is within the valid space of this topology.
  bool contains(NodeId node);

  /// Whether moving from [node] in [direction] would exit the space
  /// (i.e., there is no valid neighbor in that direction).
  bool isExitBoundary(NodeId node, Direction direction);
}

/// Aggregate facade combining all spatial contracts.
/// Use cases that need full spatial reasoning depend on this.
abstract class Topology
    implements TrajectoryProvider, AdjacencyProvider, BoundaryProvider {
  /// Total number of discrete nodes in the space.
  int get nodeCount;

  /// All valid directions supported by this topology.
  List<Direction> get supportedDirections;
}
