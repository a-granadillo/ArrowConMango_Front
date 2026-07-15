import 'dart:math' as math;

/// Alias for [ArrowBlockingGraph], matching the domain vocabulary used by
/// issue #43 ("ArrowGraph domain service, Kahn algorithm for hasCycle").
/// Topology-agnostic: the same graph serves 2D and 3D boards alike.
typedef ArrowGraph = ArrowBlockingGraph;

/// Represents a directed dependency graph where nodes are arrow IDs
/// and directed edges represent blocking relationships.
///
/// An edge A → B means "Arrow A blocks Arrow B" (i.e. Arrow A must exit
/// the board before Arrow B can).
///
/// A level is mathematically solvable if and only if this graph is a
/// Directed Acyclic Graph (DAG) and has no cycles.
class ArrowBlockingGraph {
  /// Map of arrow ID to the set of arrow IDs that it directly blocks.
  /// (Out-edges: who do I block?)
  final Map<String, Set<String>> _adjacencyList = {};

  /// Map of arrow ID to the set of arrow IDs that directly block it.
  /// (In-edges: who is blocking me?)
  final Map<String, Set<String>> _inDegrees = {};

  /// All unique arrow IDs present in the graph.
  final Set<String> _nodes = {};

  /// Creates an empty blocking dependency graph.
  ArrowBlockingGraph();

  /// All arrow IDs currently in the graph.
  Iterable<String> get nodes => _nodes;

  /// Number of unique arrows in the graph.
  int get nodeCount => _nodes.length;

  /// Adds an arrow ID node to the graph if it doesn't exist.
  void addNode(String arrowId) {
    _nodes.add(arrowId);
    _adjacencyList.putIfAbsent(arrowId, () => {});
    _inDegrees.putIfAbsent(arrowId, () => {});
  }

  /// Adds a directed edge: [from] blocks [to] (from → to).
  ///
  /// This implies [from] must exit the board before [to] can exit.
  void addBlockage({required String from, required String to}) {
    addNode(from);
    addNode(to);
    _adjacencyList[from]!.add(to);
    _inDegrees[to]!.add(from);
  }

  /// Removes an arrow from the graph, liberating any arrows it was blocking.
  ///
  /// Returns a new [ArrowBlockingGraph] with the node and its connections removed
  /// to maintain immutability.
  ArrowBlockingGraph removeNode(String arrowId) {
    final nextGraph = ArrowBlockingGraph();
    for (final node in _nodes) {
      if (node == arrowId) continue;
      nextGraph.addNode(node);
    }

    for (final source in _adjacencyList.keys) {
      if (source == arrowId) continue;
      for (final target in _adjacencyList[source]!) {
        if (target == arrowId) continue;
        nextGraph.addBlockage(from: source, to: target);
      }
    }
    return nextGraph;
  }

  /// Returns a list of all arrows that are currently free to exit
  /// (i.e., they have an in-degree of 0, meaning nothing is blocking them).
  List<String> getFreeArrows() {
    final free = <String>[];
    for (final node in _nodes) {
      if (_inDegrees[node]?.isEmpty ?? true) {
        free.add(node);
      }
    }
    return free;
  }

  /// Uses Kahn's algorithm to determine if the graph has any cycles (deadlocks).
  bool hasCycle() {
    return topologicalSort() == null;
  }

  /// Performs a topological sort using Kahn's algorithm.
  ///
  /// Returns a valid sequence of arrow removals to solve the level.
  /// Returns `null` if the graph contains cycles (the level is unsolvable).
  List<String>? topologicalSort() {
    final result = <String>[];
    
    // Create a mutable copy of the in-degrees Map
    final inDegreeCopy = <String, Set<String>>{
      for (final node in _nodes) node: Set<String>.from(_inDegrees[node] ?? {}),
    };

    // Queue of nodes with no incoming edges (free arrows)
    final queue = getFreeArrows();

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      result.add(current);

      final neighbors = _adjacencyList[current] ?? {};
      for (final neighbor in neighbors) {
        inDegreeCopy[neighbor]?.remove(current);
        if (inDegreeCopy[neighbor]?.isEmpty ?? false) {
          queue.add(neighbor);
        }
      }
    }

    // If result length doesn't match total node count, there is a cycle!
    if (result.length != _nodes.length) {
      return null;
    }

    return result;
  }

  /// Calculates the maximum depth of the DAG, representing the longest sequence
  /// of consecutive blockages.
  ///
  /// For example, a depth of 3 means you must do A -> B -> C in order to exit.
  /// Higher depth represents a more complex, sequential puzzle.
  /// Returns `0` if the graph is empty or contains cycles.
  int getMaxDepth() {
    // Single topological sort pass: null means cycle or empty → depth 0.
    final sorted = topologicalSort();
    if (sorted == null) return 0;

    final depths = <String, int>{for (final node in sorted) node: 1};

    var maxDepth = 0;
    for (final node in sorted) {
      final currentDepth = depths[node] ?? 1;
      maxDepth = math.max(maxDepth, currentDepth);

      final neighbors = _adjacencyList[node] ?? {};
      for (final neighbor in neighbors) {
        depths[neighbor] = math.max(depths[neighbor] ?? 1, currentDepth + 1);
      }
    }

    return maxDepth;
  }
}
