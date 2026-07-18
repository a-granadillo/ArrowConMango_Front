import 'dart:math';

import '../../domain/entities/arrow_entity.dart';
import '../../domain/entities/board_geometry.dart';
import '../../domain/entities/board_state.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/spatial_direction.dart';
import '../../domain/services/collision_validator.dart';
import '../topologies/grid_3d_topology.dart';

/// Configuration for a dense, single-cell 3D cube level.
class CubeLevelConfig {
  final int width; // x extent
  final int height; // y extent
  final int depth; // z extent

  /// Target fraction of cells to occupy with a 1-cell arrow (0.0-1.0).
  final double fillRatio;

  const CubeLevelConfig({
    required this.width,
    required this.height,
    required this.depth,
    required this.fillRatio,
  });
}

/// Deterministic, **provably-solvable** generator for the "Tap Away"-style
/// cube UI: every occupied cell holds exactly one [ArrowEntity] of length 1,
/// pointing in one of the six [SpatialDirection]s.
///
/// ## Why the output is always solvable
/// Cells are filled one at a time. A candidate cell+direction is accepted
/// only when its exit trajectory (head to the cube's boundary, via
/// [Grid3DTopology.getTrajectory]) is clear of every cell occupied so far.
/// Removing the arrows in the **reverse** of insertion order is therefore
/// always a valid solution: when arrow A is removed, every arrow inserted
/// after A has already been removed, and A's exit path was verified clear of
/// every arrow inserted *before* A — so the path is still clear. (Identical
/// monotone-exit argument used by [LevelGenerator] and [LevelGenerator3D],
/// specialized to single-cell arrows.)
class CubeLevelGenerator {
  CubeLevelGenerator._();

  static Level generate({
    required int id,
    required String name,
    required CubeLevelConfig config,
    required int seed,
  }) {
    final topology = Grid3DTopology(
      width: config.width,
      height: config.height,
      depth: config.depth,
    );

    final totalCells = config.width * config.height * config.depth;
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
      'CubeLevelGenerator produced an unsolvable board — the monotone-exit '
      'invariant was violated, which should be impossible by construction.',
    );

    return Level(
      levelId: id,
      name: name,
      geometry: BoardGeometry3D(
        rows: config.height,
        cols: config.width,
        depth: config.depth,
      ),
      templateBoard: BoardState(arrows: bestArrows),
    );
  }

  static List<ArrowEntity> _fillBoard(
    Random rng,
    CubeLevelConfig config,
    Grid3DTopology topology,
    int targetCount,
  ) {
    final occupied = <String>{};
    final arrows = <ArrowEntity>[];
    var seq = 1;
    var attempts = 0;
    final maxAttempts = targetCount * 60;

    while (arrows.length < targetCount && attempts < maxAttempts) {
      attempts++;
      final candidate = _tryPlaceOne(rng, occupied, topology, 'c$seq');
      if (candidate == null) continue;
      seq++;
      arrows.add(candidate.entity);
      occupied.add(candidate.cellKey);
    }

    return arrows;
  }

  /// Picks a random empty cell and tries every direction (shuffled) until one
  /// has a clear exit trajectory, maximizing how many cells can be filled.
  static _CubeCandidate? _tryPlaceOne(
    Random rng,
    Set<String> occupied,
    Grid3DTopology topology,
    String id,
  ) {
    final x = rng.nextInt(topology.width);
    final y = rng.nextInt(topology.height);
    final z = rng.nextInt(topology.depth);
    final head = Cube3DNodeId(x: x, y: y, z: z);
    if (occupied.contains(head.key)) return null;

    final dirs = List<SpatialDirection>.from(SpatialDirection.values)
      ..shuffle(rng);

    for (final dir in dirs) {
      final exitPath = topology.getTrajectory(head, dir);
      final clear = exitPath.every(
        (n) => n is! Cube3DNodeId || !occupied.contains(n.key),
      );
      if (clear) {
        return _CubeCandidate(
          ArrowEntity(id: id, direction: dir, occupiedNodes: [head]),
          head.key,
        );
      }
    }

    return null;
  }

  /// Greedy drain check reusing the production [CollisionValidator]: repeatedly
  /// removes any arrow whose exit path is clear until nothing can move.
  static bool _isSolvable(List<ArrowEntity> arrows, Grid3DTopology topology) {
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

class _CubeCandidate {
  const _CubeCandidate(this.entity, this.cellKey);
  final ArrowEntity entity;
  final String cellKey;
}
