import '../entities/direction.dart';
import '../entities/node_id.dart';

/// Abstract graph structure for spatial reasoning.
///
/// A graph consists of nodes (vertices) connected by edges.
/// Each edge has a direction label that identifies the type of connection.
///
/// This abstraction allows the domain to reason about spatial relationships
/// without knowing the concrete topology (grid, hexagonal, 3D, etc.).
abstract class Graph<V extends NodeId> {
  /// Total number of nodes in the graph.
  int get nodeCount;

  /// All nodes in the graph.
  Iterable<V> get nodes;

  /// Returns the neighbor of [node] in [direction], or null if no edge exists.
  V? getNeighbor(V node, Direction direction);

  /// Returns all valid directions from [node] (edges that exist).
  List<Direction> getValidDirections(V node);

  /// Returns all neighbors of [node] with their connecting directions.
  Map<Direction, V> getNeighbors(V node);

  /// Whether [node] exists in the graph.
  bool containsNode(V node);

  /// Whether moving from [node] in [direction] would exit the graph
  /// (i.e., there is no edge in that direction).
  bool isBoundary(V node, Direction direction);

  /// Returns the ordered list of nodes from [start] (exclusive) to the
  /// boundary of the graph (inclusive), traveling in [direction].
  ///
  /// The [start] node itself is NOT included in the result.
  /// The final element is the last valid node before exiting the graph.
  ///
  /// Throws [ArgumentError] if [direction] is not valid for this graph.
  List<V> getTrajectory(V start, Direction direction);

  /// Returns the ordered list of nodes occupied by an entity of [length]
  /// after it has slid [steps] forward from its current [headPosition].
  ///
  /// Used to compute the entity's new occupied nodes after a partial slide.
  List<V> getShiftedNodes({
    required V headPosition,
    required Direction direction,
    required int length,
    required int steps,
  });
}

/// Factory interface for building graphs from topology parameters.
abstract class GraphBuilder<V extends NodeId> {
  /// Builds a graph with the given parameters.
  Graph<V> build();
}
