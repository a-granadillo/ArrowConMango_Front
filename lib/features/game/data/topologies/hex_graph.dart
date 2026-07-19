import '../../domain/entities/direction.dart';
import '../../domain/entities/hex_direction.dart';
import '../../domain/entities/node_id.dart';
import '../../domain/services/graph.dart';

/// Concrete NodeId for hexagonal boards (Layer 4).
///
/// Axial coordinates (q, r) address a pointy-top hex cell; the implicit
/// cube coordinate `s = -q - r` is derived on demand rather than stored,
/// since it carries no independent information.
class HexNodeId extends NodeId {
  final int q;
  final int r;

  const HexNodeId({required this.q, required this.r});

  /// The redundant cube coordinate, useful for bounds/distance checks.
  int get s => -q - r;

  @override
  String get key => '${q}_$r';

  @override
  List<Object?> get props => [q, r];
}

/// Concrete graph implementation for hexagonal boards (Layer 4 —
/// Infrastructure).
///
/// The board is a hexagon of pointy-top cells of the given [radius],
/// centered on axial (0, 0): a cell (q, r) belongs to the board when
/// `max(|q|, |r|, |q + r|) <= radius`. Edges connect the six neighbors with
/// [HexDirection] labels, using the standard pointy-top axial vectors
/// (see redblobgames.com/grids/hexagons):
///   n=(0,-1) ne=(+1,-1) se=(+1,0) s=(0,+1) sw=(-1,+1) nw=(-1,0)
///
/// This is the ONLY class that knows about (q, r) arithmetic. The domain
/// layer interacts through the [Graph] interface.
class HexGraph implements Graph<HexNodeId> {
  final int radius;

  /// Precomputed adjacency list for O(1) neighbor lookups.
  /// Key: node key (e.g., "1_-2"), Value: map of direction -> neighbor node.
  final Map<String, Map<Direction, HexNodeId>> _adjacency;

  /// Precomputed boundary information.
  /// Key: node key, Value: set of directions that exit the graph.
  final Map<String, Set<Direction>> _boundaries;

  HexGraph._({
    required this.radius,
    required this._adjacency,
    required this._boundaries,
  });

  factory HexGraph.build({required int radius}) {
    final adjacency = <String, Map<Direction, HexNodeId>>{};
    final boundaries = <String, Set<Direction>>{};

    for (var q = -radius; q <= radius; q++) {
      final rMin = _max(-radius, -q - radius);
      final rMax = _min(radius, -q + radius);
      for (var r = rMin; r <= rMax; r++) {
        final node = HexNodeId(q: q, r: r);
        final neighbors = <Direction, HexNodeId>{};
        final boundaryDirs = <Direction>{};

        for (final dir in HexDirection.values) {
          final neighbor = _computeNeighbor(q, r, dir);
          if (_isValid(neighbor, radius)) {
            neighbors[dir] = neighbor;
          } else {
            boundaryDirs.add(dir);
          }
        }

        adjacency[node.key] = neighbors;
        boundaries[node.key] = boundaryDirs;
      }
    }

    return HexGraph._(
      radius: radius,
      adjacency: adjacency,
      boundaries: boundaries,
    );
  }

  static int _max(int a, int b) => a > b ? a : b;
  static int _min(int a, int b) => a < b ? a : b;

  static HexNodeId _computeNeighbor(int q, int r, HexDirection direction) {
    switch (direction) {
      case HexDirection.n:
        return HexNodeId(q: q, r: r - 1);
      case HexDirection.ne:
        return HexNodeId(q: q + 1, r: r - 1);
      case HexDirection.se:
        return HexNodeId(q: q + 1, r: r);
      case HexDirection.s:
        return HexNodeId(q: q, r: r + 1);
      case HexDirection.sw:
        return HexNodeId(q: q - 1, r: r + 1);
      case HexDirection.nw:
        return HexNodeId(q: q - 1, r: r);
    }
  }

  static bool _isValid(HexNodeId node, int radius) {
    final s = node.s;
    final maxAbs = _max(node.q.abs(), _max(node.r.abs(), s.abs()));
    return maxAbs <= radius;
  }

  @override
  int get nodeCount => _adjacency.length;

  @override
  Iterable<HexNodeId> get nodes sync* {
    for (var q = -radius; q <= radius; q++) {
      final rMin = _max(-radius, -q - radius);
      final rMax = _min(radius, -q + radius);
      for (var r = rMin; r <= rMax; r++) {
        yield HexNodeId(q: q, r: r);
      }
    }
  }

  @override
  HexNodeId? getNeighbor(HexNodeId node, Direction direction) {
    final neighbors = _adjacency[node.key];
    return neighbors?[direction];
  }

  @override
  List<Direction> getValidDirections(HexNodeId node) {
    final neighbors = _adjacency[node.key];
    if (neighbors == null) return [];
    return neighbors.keys.toList();
  }

  @override
  Map<Direction, HexNodeId> getNeighbors(HexNodeId node) {
    return _adjacency[node.key] ?? {};
  }

  @override
  bool containsNode(HexNodeId node) {
    return _adjacency.containsKey(node.key);
  }

  @override
  bool isBoundary(HexNodeId node, Direction direction) {
    final bounds = _boundaries[node.key];
    return bounds?.contains(direction) ?? false;
  }

  @override
  List<HexNodeId> getTrajectory(HexNodeId start, Direction direction) {
    final hexDirection = _castDirection(direction);
    final result = <HexNodeId>[];
    var current = start;

    while (true) {
      final next = getNeighbor(current, hexDirection);
      if (next == null) break;
      result.add(next);
      current = next;
    }

    return result;
  }

  @override
  List<HexNodeId> getShiftedNodes({
    required HexNodeId headPosition,
    required Direction direction,
    required int length,
    required int steps,
  }) {
    final hexDirection = _castDirection(direction);
    final opposite = _opposite(hexDirection);

    // Move head forward by steps
    var newHead = headPosition;
    for (var i = 0; i < steps; i++) {
      final next = getNeighbor(newHead, hexDirection);
      if (next == null) break;
      newHead = next;
    }

    // Build the shifted path backwards from new head
    final nodesReversed = <HexNodeId>[];
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

  HexDirection _castDirection(Direction direction) {
    if (direction is! HexDirection) {
      throw ArgumentError(
        'Expected HexDirection, got ${direction.runtimeType}',
      );
    }
    return direction;
  }

  HexDirection _opposite(HexDirection direction) {
    switch (direction) {
      case HexDirection.n:
        return HexDirection.s;
      case HexDirection.s:
        return HexDirection.n;
      case HexDirection.ne:
        return HexDirection.sw;
      case HexDirection.sw:
        return HexDirection.ne;
      case HexDirection.se:
        return HexDirection.nw;
      case HexDirection.nw:
        return HexDirection.se;
    }
  }
}

/// Builder for [HexGraph].
class HexGraphBuilder implements GraphBuilder<HexNodeId> {
  final int radius;

  const HexGraphBuilder({required this.radius});

  @override
  Graph<HexNodeId> build() {
    return HexGraph.build(radius: radius);
  }
}

/// The [HexDirection] from [from] to [to], if they are hex-adjacent; null
/// otherwise. The inverse of stepping one hex in a direction — used when
/// serializing an arrow's body (an ordered list of nodes) back into
/// direction segments, e.g. for the creative-mode hex level editor/mapper
/// (mirrors how `ArrowMapper._inferDirection` does the same for grids).
HexDirection? hexDirectionBetween(HexNodeId from, HexNodeId to) {
  final dq = to.q - from.q;
  final dr = to.r - from.r;
  for (final dir in HexDirection.values) {
    final (vq, vr) = _hexVector(dir);
    if (vq == dq && vr == dr) return dir;
  }
  return null;
}

(int, int) _hexVector(HexDirection direction) => switch (direction) {
      HexDirection.n => (0, -1),
      HexDirection.ne => (1, -1),
      HexDirection.se => (1, 0),
      HexDirection.s => (0, 1),
      HexDirection.sw => (-1, 1),
      HexDirection.nw => (-1, 0),
    };
