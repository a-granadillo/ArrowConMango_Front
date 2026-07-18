import '../../../domain/entities/arrow_entity.dart';
import '../../../domain/entities/hex_direction.dart';
import '../../topologies/hex_graph.dart';
import '../../topologies/hex_topology.dart';

/// Converts [ArrowEntity] to/from the backend's hexagonal-level JSON shape
/// (`startNode: {q,r}`, `trajectory.segments: [{direction, length}]`).
///
/// The hex sibling of `ArrowMapper` (which only supports
/// [Grid2DNodeId]/[CardinalDirection]) — shared by [HexLevelRepository]
/// (read-only catalogue) and the creative-mode hex repository (read+write),
/// so the wire format is defined exactly once.
class HexArrowMapper {
  const HexArrowMapper._();

  /// Walks [json]'s trajectory segments into the arrow's occupied nodes.
  ///
  /// Mirrors the backend's `_trajectoryInBoardNodes` exactly: at each step,
  /// the *current* node is pushed to the body **before** advancing — so a
  /// segment of length L contributes L body cells, not L+1. The position
  /// after the very last advance (the arrow's eventual exit step) is never
  /// pushed, matching how the backend validates bodies but allows the final
  /// exit step to cross the board boundary.
  static ArrowEntity fromJson(
    Map<String, dynamic> json,
    HexTopology topology,
  ) {
    final startNode = json['startNode'] as Map<String, dynamic>;
    var current = HexNodeId(
      q: startNode['q'] as int,
      r: startNode['r'] as int,
    );
    final segments = (json['trajectory'] as Map<String, dynamic>)['segments']
        as List<dynamic>;

    final body = <HexNodeId>[];
    var lastDirection = HexDirection.n;
    outer:
    for (final segment in segments) {
      final segmentMap = segment as Map<String, dynamic>;
      final direction = _directionFromString(segmentMap['direction'] as String);
      lastDirection = direction;
      final length = segmentMap['length'] as int;
      for (var step = 0; step < length; step++) {
        body.add(current);
        final next = topology.getNeighbor(current, direction);
        if (next == null) break outer;
        current = next as HexNodeId;
      }
    }

    return ArrowEntity(
      id: json['id'] as String,
      direction: lastDirection,
      occupiedNodes: body,
      isSwitchable: json['isSwitchable'] as bool? ?? false,
    );
  }

  /// Serializes [arrow]'s body back into `startNode` + `trajectory.segments`,
  /// grouping consecutive same-direction steps into one segment each — the
  /// inverse of [fromJson].
  ///
  /// Because [fromJson] pushes a segment's *current* node before advancing,
  /// a body of N cells only has N-1 *visible* hops between them — the final
  /// segment's very last push has no following hop recorded (its advance
  /// target is either the next segment's continuation or the eventual exit,
  /// neither of which is part of the body). So after grouping the N-1 hops
  /// into segments, the **last** segment's length is bumped by 1 to recover
  /// the true total (sum of segment lengths == N, matching how [fromJson]
  /// and the backend's `_trajectoryInBoardNodes` count it).
  static Map<String, dynamic> toJson(ArrowEntity arrow) {
    final nodes = arrow.occupiedNodes.cast<HexNodeId>();
    if (nodes.isEmpty) {
      throw ArgumentError('ArrowEntity must have at least one occupied node');
    }

    if (nodes.length == 1) {
      final direction = arrow.direction;
      if (direction is! HexDirection) {
        throw ArgumentError(
          'HexArrowMapper only supports HexDirection, got ${direction.runtimeType}.',
        );
      }
      return {
        'id': arrow.id,
        'startNode': {'q': nodes.first.q, 'r': nodes.first.r},
        'trajectory': {
          'segments': [
            {'direction': direction.name, 'length': 1},
          ],
        },
        'isSwitchable': arrow.isSwitchable,
      };
    }

    final directions = <HexDirection>[];
    for (var i = 0; i < nodes.length - 1; i++) {
      final dir = hexDirectionBetween(nodes[i], nodes[i + 1]);
      if (dir == null) {
        throw ArgumentError(
          'Nodes ${nodes[i]} and ${nodes[i + 1]} are not hex-adjacent.',
        );
      }
      directions.add(dir);
    }

    final segments = <Map<String, dynamic>>[];
    var currentDirection = directions[0];
    var currentLength = 1;
    for (var i = 1; i < directions.length; i++) {
      if (directions[i] == currentDirection) {
        currentLength++;
      } else {
        segments.add({'direction': currentDirection.name, 'length': currentLength});
        currentDirection = directions[i];
        currentLength = 1;
      }
    }
    // The last segment absorbs the invisible final push (see doc comment).
    segments.add({'direction': currentDirection.name, 'length': currentLength + 1});

    return {
      'id': arrow.id,
      'startNode': {'q': nodes.first.q, 'r': nodes.first.r},
      'trajectory': {'segments': segments},
      'isSwitchable': arrow.isSwitchable,
    };
  }

  static HexDirection _directionFromString(String raw) {
    return HexDirection.values.firstWhere(
      (d) => d.name == raw,
      orElse: () => throw ArgumentError('Unknown hex direction "$raw"'),
    );
  }
}
