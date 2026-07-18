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

  /// Maximum body length (in hexagons) an arrow may span.
  final int maxArrowLength;

  const HexLevelConfig({
    required this.radius,
    required this.fillRatio,
    this.maxArrowLength = 1,
  });
}

/// Deterministic, **provably-solvable** generator for hexagonal-board levels.
/// An arrow may span one or more hexagons (straight body, per
/// [HexLevelConfig.maxArrowLength]), pointing in one of the six
/// [HexDirection]s.
///
/// ## Why the output is always solvable
/// Arrows are placed one at a time. A candidate placement is accepted only
/// when (a) every cell of its body lies within the board and is unoccupied,
/// and (b) its exit trajectory (head to the board's boundary, via
/// [HexTopology.getTrajectory]) is clear of every cell occupied so far.
/// Removing the arrows in the **reverse** of insertion order is therefore
/// always a valid solution: when arrow A is removed, every arrow inserted
/// after A has already been removed, and A's exit path was verified clear of
/// every arrow inserted *before* A — so the path is still clear. (Same
/// monotone-exit argument used by [CubeLevelGenerator]/[LevelGenerator].)
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
      final candidate = _tryPlaceOne(
        rng,
        occupied,
        topology,
        allNodes,
        config.maxArrowLength,
        'h$seq',
      );
      if (candidate == null) continue;
      seq++;
      arrows.add(candidate.entity);
      occupied.addAll(candidate.cellKeys);
    }

    return arrows;
  }

  /// Picks a random empty head cell, a random body length and direction, and
  /// accepts the first combination (shuffled) whose body is unoccupied and
  /// whose exit trajectory is clear.
  static _HexCandidate? _tryPlaceOne(
    Random rng,
    Set<String> occupied,
    HexTopology topology,
    List<HexNodeId> allNodes,
    int maxLength,
    String id,
  ) {
    final head = allNodes[rng.nextInt(allNodes.length)];
    if (occupied.contains(head.key)) return null;

    final dirs = List<HexDirection>.from(HexDirection.values)..shuffle(rng);

    for (final dir in dirs) {
      final length = 1 + rng.nextInt(maxLength);
      final body = _buildBody(topology, head, dir, length);
      if (body == null) continue;
      if (body.any((n) => occupied.contains(n.key))) continue;

      final exitPath = topology.getTrajectory(head, dir);
      final clear = exitPath.every(
        (n) => n is! HexNodeId || !occupied.contains(n.key),
      );
      if (!clear) continue;

      return _HexCandidate(
        ArrowEntity(id: id, direction: dir, occupiedNodes: body),
        body.map((n) => n.key).toSet(),
      );
    }

    return null;
  }

  /// Walks backward from [head] (the arrow's tip) along the opposite of
  /// [direction] to build the ordered tail->head body. Returns null if the
  /// body would fall off the board (arrows must be fully on-board at rest).
  static List<HexNodeId>? _buildBody(
    HexTopology topology,
    HexNodeId head,
    HexDirection direction,
    int length,
  ) {
    final opposite = _opposite(direction);
    final bodyReversed = <HexNodeId>[head];
    var current = head;
    for (var i = 1; i < length; i++) {
      final prevRaw = topology.getNeighbor(current, opposite);
      if (prevRaw == null) return null;
      final prev = prevRaw as HexNodeId;
      bodyReversed.add(prev);
      current = prev;
    }
    return bodyReversed.reversed.toList();
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
