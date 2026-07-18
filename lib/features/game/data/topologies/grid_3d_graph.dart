import '../../domain/entities/direction.dart';
import '../../domain/entities/spatial_direction.dart';
import '../../domain/services/graph.dart';
import 'grid_3d_topology.dart';

/// Concrete graph implementation for 3D grids (Layer 4 — Infrastructure).
///
/// Each cell (x, y, z) is a node, where x = column, y = row, z = depth
/// (layer). Edges connect the six orthogonal neighbors with
/// [SpatialDirection] labels:
///   right → +x, left → -x, down → +y, up → -y, back → +z, fwd → -z.
///
/// This is the ONLY class that knows about (x, y, z) arithmetic.
/// The domain layer interacts through the [Graph] interface.
class Grid3DGraph implements Graph<Cube3DNodeId> {
  final int width; // x extent
  final int height; // y extent
  final int depth; // z extent

  /// Precomputed adjacency list for O(1) neighbor lookups.
  /// Key: node key (e.g., "2_3_1"), Value: map of direction -> neighbor node.
  final Map<String, Map<Direction, Cube3DNodeId>> _adjacency;

  /// Precomputed boundary information.
  /// Key: node key, Value: set of directions that exit the graph.
  final Map<String, Set<Direction>> _boundaries;

  Grid3DGraph._({
    required this.width,
    required this.height,
    required this.depth,
    required this._adjacency,
    required this._boundaries,
  });

  factory Grid3DGraph.build({
    required int width,
    required int height,
    required int depth,
  }) {
    final adjacency = <String, Map<Direction, Cube3DNodeId>>{};
    final boundaries = <String, Set<Direction>>{};

    for (var z = 0; z < depth; z++) {
      for (var y = 0; y < height; y++) {
        for (var x = 0; x < width; x++) {
          final node = Cube3DNodeId(x: x, y: y, z: z);
          final neighbors = <Direction, Cube3DNodeId>{};
          final boundaryDirs = <Direction>{};

          for (final dir in SpatialDirection.values) {
            final neighbor = _computeNeighbor(x, y, z, dir);
            if (_isValid(neighbor, width, height, depth)) {
              neighbors[dir] = neighbor;
            } else {
              boundaryDirs.add(dir);
            }
          }

          adjacency[node.key] = neighbors;
          boundaries[node.key] = boundaryDirs;
        }
      }
    }

    return Grid3DGraph._(
      width: width,
      height: height,
      depth: depth,
      adjacency: adjacency,
      boundaries: boundaries,
    );
  }

  static Cube3DNodeId _computeNeighbor(
    int x,
    int y,
    int z,
    SpatialDirection direction,
  ) {
    switch (direction) {
      case SpatialDirection.up:
        return Cube3DNodeId(x: x, y: y - 1, z: z);
      case SpatialDirection.down:
        return Cube3DNodeId(x: x, y: y + 1, z: z);
      case SpatialDirection.left:
        return Cube3DNodeId(x: x - 1, y: y, z: z);
      case SpatialDirection.right:
        return Cube3DNodeId(x: x + 1, y: y, z: z);
      case SpatialDirection.fwd:
        return Cube3DNodeId(x: x, y: y, z: z - 1);
      case SpatialDirection.back:
        return Cube3DNodeId(x: x, y: y, z: z + 1);
    }
  }

  static bool _isValid(Cube3DNodeId node, int width, int height, int depth) {
    return node.x >= 0 &&
        node.x < width &&
        node.y >= 0 &&
        node.y < height &&
        node.z >= 0 &&
        node.z < depth;
  }

  @override
  int get nodeCount => width * height * depth;

  @override
  Iterable<Cube3DNodeId> get nodes sync* {
    for (var z = 0; z < depth; z++) {
      for (var y = 0; y < height; y++) {
        for (var x = 0; x < width; x++) {
          yield Cube3DNodeId(x: x, y: y, z: z);
        }
      }
    }
  }

  @override
  Cube3DNodeId? getNeighbor(Cube3DNodeId node, Direction direction) {
    final neighbors = _adjacency[node.key];
    return neighbors?[direction];
  }

  @override
  List<Direction> getValidDirections(Cube3DNodeId node) {
    final neighbors = _adjacency[node.key];
    if (neighbors == null) return [];
    return neighbors.keys.toList();
  }

  @override
  Map<Direction, Cube3DNodeId> getNeighbors(Cube3DNodeId node) {
    return _adjacency[node.key] ?? {};
  }

  @override
  bool containsNode(Cube3DNodeId node) {
    return _adjacency.containsKey(node.key);
  }

  @override
  bool isBoundary(Cube3DNodeId node, Direction direction) {
    final bounds = _boundaries[node.key];
    return bounds?.contains(direction) ?? false;
  }

  @override
  List<Cube3DNodeId> getTrajectory(Cube3DNodeId start, Direction direction) {
    final spatial = _castDirection(direction);
    final result = <Cube3DNodeId>[];
    var current = start;

    while (true) {
      final next = getNeighbor(current, spatial);
      if (next == null) break;
      result.add(next);
      current = next;
    }

    return result;
  }

  @override
  List<Cube3DNodeId> getShiftedNodes({
    required Cube3DNodeId headPosition,
    required Direction direction,
    required int length,
    required int steps,
  }) {
    final spatial = _castDirection(direction);
    final opposite = _opposite(spatial);

    // Move head forward by steps
    var newHead = headPosition;
    for (var i = 0; i < steps; i++) {
      final next = getNeighbor(newHead, spatial);
      if (next == null) break;
      newHead = next;
    }

    // Build the shifted path backwards from new head
    final nodesReversed = <Cube3DNodeId>[];
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

  SpatialDirection _castDirection(Direction direction) {
    if (direction is! SpatialDirection) {
      throw ArgumentError(
        'Expected SpatialDirection, got ${direction.runtimeType}',
      );
    }
    return direction;
  }

  SpatialDirection _opposite(SpatialDirection direction) {
    switch (direction) {
      case SpatialDirection.up:
        return SpatialDirection.down;
      case SpatialDirection.down:
        return SpatialDirection.up;
      case SpatialDirection.left:
        return SpatialDirection.right;
      case SpatialDirection.right:
        return SpatialDirection.left;
      case SpatialDirection.fwd:
        return SpatialDirection.back;
      case SpatialDirection.back:
        return SpatialDirection.fwd;
    }
  }
}

/// Builder for [Grid3DGraph].
class Grid3DGraphBuilder implements GraphBuilder<Cube3DNodeId> {
  final int width;
  final int height;
  final int depth;

  const Grid3DGraphBuilder({
    required this.width,
    required this.height,
    required this.depth,
  });

  @override
  Graph<Cube3DNodeId> build() {
    return Grid3DGraph.build(width: width, height: height, depth: depth);
  }
}
