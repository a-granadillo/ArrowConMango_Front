import 'dart:math';

import '../../domain/entities/arrow_entity.dart';
import '../../domain/entities/board_geometry.dart';
import '../../domain/entities/board_state.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/spatial_direction.dart';
import '../../domain/services/arrow_blocking_graph.dart';
import '../../domain/services/collision_validator.dart';
import '../topologies/grid_3d_topology.dart';

/// Configuration for 3D level generation.
///
/// Mirrors [LevelConfig] (the 2D generator's configuration), extended with
/// a `depth` (Z) axis. No silhouettes yet: 3D levels are rectangular volumes.
class LevelConfig3D {
  final int width; // x extent
  final int height; // y extent
  final int depth; // z extent
  final int arrowCount;
  final double straightRatio;
  final double lShapeRatio;
  final double zShapeRatio;
  final int minSegmentLength;
  final int maxSegmentLength;
  final int minGraphDepth;
  final double switchableRatio;

  const LevelConfig3D({
    required this.width,
    required this.height,
    required this.depth,
    required this.arrowCount,
    required this.straightRatio,
    required this.lShapeRatio,
    required this.zShapeRatio,
    required this.minSegmentLength,
    required this.maxSegmentLength,
    required this.minGraphDepth,
    this.switchableRatio = 0.0,
  });
}

/// Deterministic, **provably-solvable** 3D level generator.
///
/// Generalizes [LevelGenerator]'s reverse-procedural approach to a cubic
/// volume: arrows are added one at a time, accepted only if their body and
/// exit trajectory (computed via [Grid3DTopology]) are clear. Removing
/// arrows in the reverse of insertion order is therefore always a valid
/// solution (see [LevelGenerator]'s class doc for the full monotone-exit
/// argument, which applies unchanged in 3D).
///
/// Unlike the 2D generator (which works on serializable models and
/// reimplements cell arithmetic), this generator builds domain entities
/// ([ArrowEntity], [BoardState], [Level]) directly, reusing [Grid3DTopology]
/// for exit-trajectory checks and [CollisionValidator] / [ArrowGraph] (Kahn)
/// for solvability and complexity gating.
class LevelGenerator3D {
  LevelGenerator3D._();

  static Level generate({
    required int id,
    required String name,
    required LevelConfig3D config,
    required int seed,
  }) {
    final topology = Grid3DTopology(
      width: config.width,
      height: config.height,
      depth: config.depth,
    );

    var currentSeed = seed;
    var boardAttempts = 0;
    List<ArrowEntity> arrows = [];

    while (boardAttempts < 1000) {
      boardAttempts++;
      final rng = Random(currentSeed);
      final occupied = <String>{};
      arrows = <ArrowEntity>[];
      var seq = 1;

      var attempts = 0;
      final maxAttempts = config.arrowCount * 1200;
      while (arrows.length < config.arrowCount && attempts < maxAttempts) {
        attempts++;
        final candidate = _tryMakeArrow(
          rng,
          occupied,
          arrows.length,
          config,
          topology,
          'l$seq',
        );
        if (candidate == null) continue;
        seq++;
        arrows.add(candidate.entity);
        occupied.addAll(candidate.cellKeys);
      }

      if (arrows.length < config.arrowCount) {
        currentSeed++;
        continue;
      }

      final graph = _buildBlockingGraph(arrows, topology);
      final solvable = _isSolvable(arrows, topology);

      if (graph.getMaxDepth() >= config.minGraphDepth && solvable) {
        break; // Meets complexity target AND is solvable.
      }

      currentSeed++;
    }

    if (!_isSolvable(arrows, topology)) {
      // Safety net: regenerate with a minimal, guaranteed-solvable config.
      return LevelGenerator3D.generate(
        id: id,
        name: name,
        config: LevelConfig3D(
          width: config.width,
          height: config.height,
          depth: config.depth,
          arrowCount: (config.arrowCount * 0.4).round().clamp(
                4,
                config.arrowCount,
              ),
          straightRatio: 0.6,
          lShapeRatio: 0.4,
          zShapeRatio: 0.0,
          minSegmentLength: config.minSegmentLength,
          maxSegmentLength: config.maxSegmentLength,
          minGraphDepth: 0,
        ),
        seed: currentSeed + 99999,
      );
    }

    var finalArrows = arrows;
    if (config.switchableRatio > 0 && arrows.isNotEmpty) {
      final switchableCount = (arrows.length * config.switchableRatio).round();
      if (switchableCount > 0) {
        final startIdx = (arrows.length * 0.2).round();
        final endIdx = arrows.length - (arrows.length * 0.1).round();
        final candidates = arrows.sublist(
          startIdx.clamp(0, arrows.length),
          endIdx.clamp(0, arrows.length),
        );
        final shuffleRng = Random(currentSeed);
        candidates.shuffle(shuffleRng);

        final switchableIds = candidates
            .take(switchableCount)
            .map((a) => a.id)
            .toSet();
        finalArrows = arrows
            .map(
              (a) => switchableIds.contains(a.id)
                  ? ArrowEntity(
                      id: a.id,
                      direction: a.direction,
                      occupiedNodes: a.occupiedNodes,
                      isSwitchable: true,
                    )
                  : a,
            )
            .toList();
      }
    }

    return Level(
      levelId: id,
      name: name,
      geometry: BoardGeometry3D(
        rows: config.height,
        cols: config.width,
        depth: config.depth,
      ),
      templateBoard: BoardState(arrows: finalArrows),
    );
  }

  /// Traverses the generated board and builds its blocking dependency graph,
  /// walking each arrow's exit trajectory via [Grid3DTopology].
  static ArrowGraph _buildBlockingGraph(
    List<ArrowEntity> arrows,
    Grid3DTopology topology,
  ) {
    final graph = ArrowGraph();
    for (final arrow in arrows) {
      graph.addNode(arrow.id);
    }

    final occupancy = <String, String>{};
    for (final arrow in arrows) {
      for (final node in arrow.occupiedNodes) {
        occupancy[node.key] = arrow.id;
      }
    }

    for (final arrow in arrows) {
      final trajectory = topology.getTrajectory(arrow.headNode, arrow.direction);
      for (final node in trajectory) {
        final blockerId = occupancy[node.key];
        if (blockerId != null && blockerId != arrow.id) {
          graph.addBlockage(from: blockerId, to: arrow.id);
        }
      }
    }

    return graph;
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

  static (int, int, int) _offset(SpatialDirection d) => switch (d) {
        SpatialDirection.up => (0, -1, 0),
        SpatialDirection.down => (0, 1, 0),
        SpatialDirection.left => (-1, 0, 0),
        SpatialDirection.right => (1, 0, 0),
        SpatialDirection.fwd => (0, 0, -1),
        SpatialDirection.back => (0, 0, 1),
      };

  static SpatialDirection _opposite(SpatialDirection d) => switch (d) {
        SpatialDirection.up => SpatialDirection.down,
        SpatialDirection.down => SpatialDirection.up,
        SpatialDirection.left => SpatialDirection.right,
        SpatialDirection.right => SpatialDirection.left,
        SpatialDirection.fwd => SpatialDirection.back,
        SpatialDirection.back => SpatialDirection.fwd,
      };

  /// The four directions perpendicular to [d] (excludes d and its opposite).
  static List<SpatialDirection> _perpendiculars(SpatialDirection d) {
    final opp = _opposite(d);
    return SpatialDirection.values
        .where((x) => x != d && x != opp)
        .toList(growable: false);
  }

  static bool _inBoard(int x, int y, int z, LevelConfig3D config) =>
      x >= 0 && x < config.width && y >= 0 && y < config.height && z >= 0 && z < config.depth;

  static bool _validCell(int x, int y, int z, Set<String> occupied, LevelConfig3D config) =>
      _inBoard(x, y, z, config) && !occupied.contains(_key(x, y, z));

  static int _minDistanceToFace(int x, int y, int z, LevelConfig3D config) {
    final candidates = [
      x,
      config.width - 1 - x,
      y,
      config.height - 1 - y,
      z,
      config.depth - 1 - z,
    ];
    return candidates.reduce(min);
  }

  static String _key(int x, int y, int z) => '${x}_${y}_$z';

  static int _randLen(Random rng, LevelConfig3D config) =>
      config.minSegmentLength +
      rng.nextInt(config.maxSegmentLength - config.minSegmentLength + 1);

  static _Candidate3D? _tryMakeArrow(
    Random rng,
    Set<String> occupied,
    int index,
    LevelConfig3D config,
    Grid3DTopology topology,
    String id,
  ) {
    final dir = SpatialDirection.values[rng.nextInt(6)];
    final (dx, dy, dz) = _offset(dir);

    final hx = rng.nextInt(config.width);
    final hy = rng.nextInt(config.height);
    final hz = rng.nextInt(config.depth);
    if (occupied.contains(_key(hx, hy, hz))) return null;

    // --- ONION EFFECT BIAS (mirrors LevelGenerator's 2D bias) ---
    // Generation runs backward: first-placed arrows are last to exit
    // (outer/most-blocked), last-placed are first to exit (inner/free).
    final progress = index / config.arrowCount;
    final faceDist = _minDistanceToFace(hx, hy, hz, config);
    if (progress < 0.35) {
      final maxFaceDist = (config.width >= 6 && config.height >= 6) ? 1 : 0;
      if (faceDist > maxFaceDist) return null;
    } else if (progress >= 0.70) {
      if (faceDist < 1) return null;
    }

    // Exit trajectory from head to boundary must be clear — reuses the
    // production Grid3DTopology instead of duplicating cell arithmetic.
    final headNode = Cube3DNodeId(x: hx, y: hy, z: hz);
    final exitPath = topology.getTrajectory(headNode, dir);
    for (final node in exitPath) {
      if (node is Cube3DNodeId && occupied.contains(_key(node.x, node.y, node.z))) {
        return null;
      }
    }

    // Build the body backward from the head (head-first, reversed at the end).
    final headFirst = <List<int>>[[hx, hy, hz]];
    var cx = hx, cy = hy, cz = hz;
    final shapeType = rng.nextDouble();

    if (shapeType < config.straightRatio) {
      // Straight arrow.
      final len = _randLen(rng, config);
      for (var i = 1; i < len; i++) {
        cx -= dx;
        cy -= dy;
        cz -= dz;
        if (!_validCell(cx, cy, cz, occupied, config)) break;
        headFirst.add([cx, cy, cz]);
      }
    } else if (shapeType < config.straightRatio + config.lShapeRatio) {
      // L-shape: one bend to a perpendicular axis.
      final lastLen = _randLen(rng, config);
      for (var i = 0; i < lastLen; i++) {
        cx -= dx;
        cy -= dy;
        cz -= dz;
        if (!_validCell(cx, cy, cz, occupied, config)) {
          return _finish(dir, headFirst, id);
        }
        headFirst.add([cx, cy, cz]);
      }
      final perps = _perpendiculars(dir);
      final (px, py, pz) = _offset(perps[rng.nextInt(perps.length)]);
      final firstLen = _randLen(rng, config);
      for (var i = 0; i < firstLen; i++) {
        cx -= px;
        cy -= py;
        cz -= pz;
        if (!_validCell(cx, cy, cz, occupied, config)) {
          return _finish(dir, headFirst, id);
        }
        headFirst.add([cx, cy, cz]);
      }
    } else {
      // Z-shape: zigzag with two bends (perpendicular, then back to dir's axis).
      final firstLen = _randLen(rng, config);
      for (var i = 0; i < firstLen; i++) {
        cx -= dx;
        cy -= dy;
        cz -= dz;
        if (!_validCell(cx, cy, cz, occupied, config)) {
          return _finish(dir, headFirst, id);
        }
        headFirst.add([cx, cy, cz]);
      }
      final perps = _perpendiculars(dir);
      final (px, py, pz) = _offset(perps[rng.nextInt(perps.length)]);
      final midLen = _randLen(rng, config);
      for (var i = 0; i < midLen; i++) {
        cx -= px;
        cy -= py;
        cz -= pz;
        if (!_validCell(cx, cy, cz, occupied, config)) {
          return _finish(dir, headFirst, id);
        }
        headFirst.add([cx, cy, cz]);
      }
      final lastLen = _randLen(rng, config);
      for (var i = 0; i < lastLen; i++) {
        cx -= dx;
        cy -= dy;
        cz -= dz;
        if (!_validCell(cx, cy, cz, occupied, config)) {
          return _finish(dir, headFirst, id);
        }
        headFirst.add([cx, cy, cz]);
      }
    }

    return _finish(dir, headFirst, id);
  }

  static _Candidate3D? _finish(
    SpatialDirection dir,
    List<List<int>> headFirst,
    String id,
  ) {
    if (headFirst.length < 2) return null;

    final cellsTailToHead = headFirst.reversed.toList();
    final nodes = cellsTailToHead
        .map((c) => Cube3DNodeId(x: c[0], y: c[1], z: c[2]))
        .toList();
    final entity = ArrowEntity(id: id, direction: dir, occupiedNodes: nodes);
    final keys = cellsTailToHead.map((c) => _key(c[0], c[1], c[2])).toSet();
    return _Candidate3D(entity, keys);
  }
}

class _Candidate3D {
  const _Candidate3D(this.entity, this.cellKeys);
  final ArrowEntity entity;
  final Set<String> cellKeys;
}
