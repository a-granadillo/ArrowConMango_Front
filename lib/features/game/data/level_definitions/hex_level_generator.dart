import 'dart:math';

import '../../domain/entities/arrow_entity.dart';
import '../../domain/entities/board_state.dart';
import '../../domain/entities/hex_direction.dart';
import '../../domain/entities/hex_level.dart';
import '../../domain/services/collision_validator.dart';
import '../topologies/hex_graph.dart';
import '../topologies/hex_topology.dart';

/// Configuration for a hexagonal-board level.
class HexLevelConfig {
  final int radius;

  /// Target fraction of cells to occupy with an arrow (0.0-1.0).
  final double fillRatio;

  /// Minimum body length (in hexagons) an arrow may span. Defaults to 2 so
  /// every arrow's shape (straight vs. its turns) is actually legible on
  /// screen — a 1-cell arrow is just a dot with a short stub.
  final int minArrowLength;

  /// Maximum body length (in hexagons) an arrow may span.
  final int maxArrowLength;

  /// Maximum number of straight direction-segments an arrow's body may be
  /// built from. `1` = always straight; `2`+ allows bent ("L"/"Z"-shaped,
  /// like the 2D mode's L/Z/U arrows) bodies that turn through one or more
  /// corners on their way from tail to head.
  final int maxSegments;

  const HexLevelConfig({
    required this.radius,
    required this.fillRatio,
    this.minArrowLength = 2,
    this.maxArrowLength = 2,
    this.maxSegments = 1,
  })  : assert(
          maxArrowLength >= minArrowLength,
          'maxArrowLength must be >= minArrowLength',
        ),
        assert(maxSegments >= 1, 'maxSegments must be >= 1');
}

/// Deterministic, **provably-solvable** generator for hexagonal-board levels.
/// An arrow spans two or more hexagons (per [HexLevelConfig.minArrowLength]/
/// [HexLevelConfig.maxArrowLength] — never a single cell, so its shape reads
/// clearly on screen) and, when [HexLevelConfig.maxSegments] > 1, may bend
/// through one or more genuine turns instead of always being a straight
/// line — the hex equivalent of the 2D mode's L/Z/U-shaped arrows.
///
/// ## Why the output is always solvable
/// Arrows are placed one at a time, walking tail→head across each of their
/// direction segments. A candidate placement is accepted only when (a)
/// every cell of its body lies within the board and is unoccupied, and (b)
/// its exit trajectory (head to the board's boundary, in the *last*
/// segment's direction, via [HexTopology.getTrajectory]) is clear of every
/// cell occupied so far. Removing the arrows in the **reverse** of
/// insertion order is therefore always a valid solution: when arrow A is
/// removed, every arrow inserted after A has already been removed, and A's
/// exit path was verified clear of every arrow inserted *before* A — so the
/// path is still clear. (Same monotone-exit argument used by
/// [CubeLevelGenerator]/[LevelGenerator]; bending the body doesn't affect
/// it, since only the head's forward trajectory is ever checked.)
class HexLevelGenerator {
  HexLevelGenerator._();

  static HexLevel generate({
    required String id,
    required String name,
    required String difficulty,
    required HexLevelConfig config,
    required int seed,
  }) {
    final topology = HexTopology(radius: config.radius);
    final totalCells = topology.nodeCount;
    final targetCount = (totalCells * config.fillRatio).round().clamp(
          1,
          totalCells,
        );

    var bestArrows = <ArrowEntity>[];
    var currentSeed = seed;
    for (var attempt = 0; attempt < 40; attempt++) {
      final arrows = _fillBoard(
        Random(currentSeed),
        config,
        topology,
        targetCount,
      );
      if (arrows.length > bestArrows.length) bestArrows = arrows;
      if (bestArrows.length >= targetCount) break;
      currentSeed++;
    }

    assert(
      _isSolvable(bestArrows, topology),
      'HexLevelGenerator produced an unsolvable board — the monotone-exit '
      'invariant was violated, which should be impossible by construction.',
    );

    return HexLevel(
      id: id,
      name: name,
      difficulty: difficulty,
      radius: config.radius,
      templateBoard: BoardState(arrows: bestArrows),
    );
  }

  static List<ArrowEntity> _fillBoard(
    Random rng,
    HexLevelConfig config,
    HexTopology topology,
    int targetCount,
  ) {
    final occupied = <String>{};
    final arrows = <ArrowEntity>[];
    var seq = 1;
    var attempts = 0;
    final maxAttempts = targetCount * 60;
    final allNodes = topology.allNodes;

    while (arrows.length < targetCount && attempts < maxAttempts) {
      attempts++;
      final candidate = _tryPlaceOne(rng, occupied, topology, allNodes, config, 'h$seq');
      if (candidate == null) continue;
      seq++;
      arrows.add(candidate.entity);
      occupied.addAll(candidate.cellKeys);
    }

    return arrows;
  }

  /// Picks a random empty tail cell and a random sequence of direction
  /// segments (turning at each segment boundary when `maxSegments` > 1),
  /// and accepts the first shuffled direction/segment-count combination
  /// whose body is unoccupied, in-bounds and non-self-intersecting, and
  /// whose exit trajectory (from the final head, in the last segment's
  /// direction) is clear.
  static _HexCandidate? _tryPlaceOne(
    Random rng,
    Set<String> occupied,
    HexTopology topology,
    List<HexNodeId> allNodes,
    HexLevelConfig config,
    String id,
  ) {
    final tail = allNodes[rng.nextInt(allNodes.length)];
    if (occupied.contains(tail.key)) return null;

    final segmentCount = 1 + rng.nextInt(config.maxSegments);
    final totalLength = max(
      segmentCount,
      config.minArrowLength +
          rng.nextInt(config.maxArrowLength - config.minArrowLength + 1),
    );
    final segmentLengths = _splitLength(rng, totalLength, segmentCount);

    for (var attempt = 0; attempt < 8; attempt++) {
      final directions = _randomSegmentDirections(rng, segmentCount);
      final built = _buildBody(topology, tail, directions, segmentLengths);
      if (built == null) continue;
      final (body, headDirection) = built;

      if (body.toSet().length != body.length) continue; // self-intersecting
      if (body.any((n) => occupied.contains(n.key))) continue;

      final head = body.last;
      final exitPath = topology.getTrajectory(head, headDirection);
      final clear = exitPath.every(
        (n) => n is! HexNodeId || !occupied.contains(n.key),
      );
      if (!clear) continue;

      return _HexCandidate(
        ArrowEntity(id: id, direction: headDirection, occupiedNodes: body),
        body.map((n) => n.key).toSet(),
      );
    }

    return null;
  }

  /// Splits [total] into [parts] positive integers (each part gets 1 first,
  /// then the remainder is handed out to random parts).
  static List<int> _splitLength(Random rng, int total, int parts) {
    final lengths = List<int>.filled(parts, 1);
    var remaining = total - parts;
    while (remaining > 0) {
      lengths[rng.nextInt(parts)]++;
      remaining--;
    }
    return lengths;
  }

  /// Picks [count] directions, one per segment: the first is unconstrained;
  /// every following one excludes the previous segment's direction *and*
  /// its opposite, guaranteeing a genuine turn (never a straight
  /// continuation nor a doubling-back over the previous segment).
  static List<HexDirection> _randomSegmentDirections(Random rng, int count) {
    final directions = <HexDirection>[];
    HexDirection? previous;
    for (var i = 0; i < count; i++) {
      final choices = previous == null
          ? HexDirection.values
          : HexDirection.values
              .where((d) => d != previous && d != _opposite(previous!))
              .toList();
      final next = choices[rng.nextInt(choices.length)];
      directions.add(next);
      previous = next;
    }
    return directions;
  }

  /// Walks forward from [tail] through each (direction, length) segment,
  /// building the ordered tail→head body. Returns null if the body would
  /// fall off the board (arrows must be fully on-board at rest). The
  /// returned direction is the *last* segment's — the direction the arrow
  /// points/exits in.
  static (List<HexNodeId>, HexDirection)? _buildBody(
    HexTopology topology,
    HexNodeId tail,
    List<HexDirection> directions,
    List<int> lengths,
  ) {
    final body = <HexNodeId>[tail];
    var current = tail;
    for (var s = 0; s < directions.length; s++) {
      for (var step = 0; step < lengths[s]; step++) {
        final nextRaw = topology.getNeighbor(current, directions[s]);
        if (nextRaw == null) return null;
        current = nextRaw as HexNodeId;
        body.add(current);
      }
    }
    return (body, directions.last);
  }

  static HexDirection _opposite(HexDirection direction) {
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

  /// Greedy drain check reusing the production [CollisionValidator]: repeatedly
  /// removes any arrow whose exit path is clear until nothing can move.
  static bool _isSolvable(List<ArrowEntity> arrows, HexTopology topology) {
    if (arrows.isEmpty) return true;
    final validator = CollisionValidator(topology);
    var board = BoardState(arrows: arrows);
    var madeProgress = true;

    while (madeProgress && !board.isEmpty) {
      madeProgress = false;
      for (final arrow in board.arrows) {
        if (validator.checkExit(arrow, board).canExit) {
          board = board.withoutArrow(arrow);
          madeProgress = true;
          break;
        }
      }
    }

    return board.isEmpty;
  }
}

class _HexCandidate {
  const _HexCandidate(this.entity, this.cellKeys);
  final ArrowEntity entity;
  final Set<String> cellKeys;
}
