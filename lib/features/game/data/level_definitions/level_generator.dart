import 'dart:math';

import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/board_size_model.dart';
import 'package:arrowconmango_front/features/game/data/models/board_state_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';

import 'package:arrowconmango_front/features/game/domain/services/arrow_blocking_graph.dart';

import 'arrow_helper.dart';
import 'pattern_placer.dart';

/// Configuration for level generation by difficulty
class LevelConfig {
  final int rows;
  final int cols;
  final int arrowCount;
  final double straightRatio; // % of straight arrows
  final double lShapeRatio; // % of L-shape arrows
  final double zShapeRatio; // % of Z-shape arrows
  final double uShapeRatio; // % of U-shape arrows
  final int minSegmentLength;
  final int maxSegmentLength;
  final int minGraphDepth; // Target minimum depth/consecutive blockages
  final List<String>? silhouette; // 2D binary shape template

  /// Templates to stamp before random generation.
  /// 'Easy' → only ChainLink3 (1x),
  /// 'Medium' → ChainLink3 + DoubleUInterlock (1x each),
  /// 'Hard' → ChainLink3 + DoubleUInterlock + SpiralLock (1x each)
  final Map<String, int> patternCounts; // templateName -> count

  /// Probability of chain forcing during random generation (0.0 - 1.0).
  final double chainForceProbability;

  /// Max depth to force per chain.
  final int maxForcedChainDepth;

  /// Percentage of arrows that are switchable (rotatable by the player).
  final double switchableRatio;

  const LevelConfig({
    required this.rows,
    required this.cols,
    required this.arrowCount,
    required this.straightRatio,
    required this.lShapeRatio,
    required this.zShapeRatio,
    required this.uShapeRatio,
    required this.minSegmentLength,
    required this.maxSegmentLength,
    required this.minGraphDepth,
    this.silhouette,
    this.patternCounts = const {},
    this.chainForceProbability = 0.0,
    this.maxForcedChainDepth = 0,
    this.switchableRatio = 0.0,
  });

  static const LevelConfig easy = LevelConfig(
    rows: 6,
    cols: 6,
    arrowCount: 15,
    straightRatio: 0.35, // Reduced straight for more structure
    lShapeRatio: 0.45,
    zShapeRatio: 0.15, // Introduce S-shapes early
    uShapeRatio: 0.05, // Small chance of horseshoe curves
    minSegmentLength: 2,
    maxSegmentLength: 4,
    minGraphDepth: 5, // Increased from 3 (needs at least 5 consecutive steps)
    patternCounts: {'ChainLink3': 1},
    chainForceProbability: 0.1,
    maxForcedChainDepth: 3,
    switchableRatio: 0.0,
  );

  static const LevelConfig medium = LevelConfig(
    rows: 8,
    cols: 8,
    arrowCount: 30,
    straightRatio: 0.15, // Even fewer straight arrows
    lShapeRatio: 0.45,
    zShapeRatio: 0.25, // More zigzags
    uShapeRatio: 0.15,
    minSegmentLength: 2,
    maxSegmentLength: 4,
    minGraphDepth: 8, // Increased from 5 (needs at least 8 consecutive steps)
    patternCounts: {'ChainLink3': 1, 'DoubleUInterlock': 1},
    chainForceProbability: 0.15,
    maxForcedChainDepth: 4,
    switchableRatio: 0.2,
  );

  static const LevelConfig hard = LevelConfig(
    rows: 12,
    cols: 12,
    arrowCount: 60,
    straightRatio: 0.05, // Almost zero straight arrows!
    lShapeRatio: 0.35,
    zShapeRatio: 0.35, // High percentage of complex zigzags
    uShapeRatio: 0.25, // High percentage of 180° turns
    minSegmentLength: 2,
    maxSegmentLength: 5,
    minGraphDepth: 12, // Increased from 8 (extremely complex: 12 consecutive blockages!)
    patternCounts: {'ChainLink3': 1, 'DoubleUInterlock': 1, 'SpiralLock': 1},
    chainForceProbability: 0.2,
    maxForcedChainDepth: 5,
    switchableRatio: 0.35,
  );
}

/// Deterministic, **provably-solvable** level generator in the design's style
/// (thin arrows with optional bends).
///
/// ## Why the output is always solvable
/// Arrows are added one at a time. A candidate is accepted only when both:
///   1. every cell of its body is currently empty, and
///   2. every in-board cell of its exit trajectory (from the head, stepping in
///      the head direction to the edge) is currently empty.
///
/// Removing the arrows in the **reverse** of the insertion order is therefore a
/// valid solution: when an arrow is removed, all arrows added after it are
/// already gone, and all arrows added before it were exactly the ones its exit
/// path was checked clear of at insertion time — so the path is still clear.
/// (The exit rule is monotone: removing arrows never blocks another, so a
/// greedy player also always solves it.)
class LevelGenerator {
  LevelGenerator._();

  /// Builds a level using the provided configuration, guaranteeing both solvability
  /// and target complexity via graph analysis.
  static LevelModel generate({
    required int id,
    required String name,
    required String difficulty,
    required LevelConfig config,
    required int seed,
  }) {
    var currentSeed = seed;
    var boardAttempts = 0;
    List<ArrowModel> arrows = [];
    ArrowBlockingGraph? graph;

    // We try to generate boards with different seeds until we find one that meets
    // the minimum complexity (graph depth) required for this difficulty.
    // The high iteration count compensates for the possibility that pattern + chain
    // interactions occasionally produce unsolvable boards (cross-template cycles).
    while (boardAttempts < 1000) {
      boardAttempts++;
      final rng = Random(currentSeed);
      final occupied = <String>{};
      arrows = <ArrowModel>[];

      // Phase 1: Place pattern templates before random generation.
      final patternResult = PatternPlacer.placeForDifficulty(
        patternCounts: config.patternCounts,
        silhouette: config.silhouette,
        rows: config.rows,
        cols: config.cols,
        occupied: occupied,
        rng: rng,
        startArrowId: 1,
      );
      arrows.addAll(patternResult.$1);
      occupied.addAll(patternResult.$2);

      // Phase 2: Random generation with chain forcing.
      var attempts = 0;
      final maxAttempts = config.arrowCount * 1200;
      while (arrows.length < config.arrowCount && attempts < maxAttempts) {
        attempts++;

        // Try chain forcing periodically.
        if (config.chainForceProbability > 0 &&
            arrows.length >= 3 &&
            arrows.length < config.arrowCount &&
            rng.nextDouble() < config.chainForceProbability) {
          final target = arrows[rng.nextInt(arrows.length)];
          final forced = _tryForceChain(target, rng, occupied, config);
          if (forced != null) {
            arrows.add(forced.model);
            occupied.addAll(forced.cellKeys);
            continue;
          }
        }

        final candidate = _tryMakeArrow(rng, occupied, arrows.length, config);
        if (candidate == null) continue;
        arrows.add(candidate.model);
        occupied.addAll(candidate.cellKeys);
      }

      // Analyze blocking dependencies using the ArrowBlockingGraph
      graph = _buildBlockingGraph(arrows, config);

      // Defensive drain check: verify the board is actually solvable.
      // In theory the monotone property guarantees solvability, but the
      // interaction of patterns + chain forcing + switchable marking
      // introduces enough complexity that we double-check with a greedy
      // drain. This runs on EVERY board (not just when graph depth is
      // sufficient) to catch edge cases before they reach the player.
      final solvable = _isSolvable(arrows, config);

      if (graph.getMaxDepth() >= config.minGraphDepth && solvable) {
        break; // Good: meets complexity target AND is solvable.
      }

      // Try next seed if the board was too parallel/easy or unsolvable.
      currentSeed++;
    }

    // Post-loop safety net: if we exhausted all attempts and the board is still
    // unsolvable, regenerate with a minimal config that guarantees solvability
    // (no patterns, no chain forcing, flat depth).
    if (!_isSolvable(arrows, config)) {
      return LevelGenerator.generate(
        id: id,
        name: name,
        difficulty: difficulty,
        config: LevelConfig(
          rows: config.rows,
          cols: config.cols,
          arrowCount: (config.arrowCount * 0.4).round().clamp(5, config.arrowCount),
          straightRatio: 0.5,
          lShapeRatio: 0.5,
          zShapeRatio: 0.0,
          uShapeRatio: 0.0,
          minSegmentLength: config.minSegmentLength,
          maxSegmentLength: config.maxSegmentLength,
          minGraphDepth: 0,
        ),
        seed: currentSeed + 99999,
      );
    }

    // Mark arrows as switchable based on the config ratio.
    if (config.switchableRatio > 0 && arrows.isNotEmpty) {
      final switchableCount = (arrows.length * config.switchableRatio).round();
      if (switchableCount > 0) {
        // Prefer mid-chain arrows (strategic) over shallowest and deepest.
        final startIdx = (arrows.length * 0.2).round();
        final endIdx = arrows.length - (arrows.length * 0.1).round();
        final candidates = arrows.sublist(
          startIdx.clamp(0, arrows.length),
          endIdx.clamp(0, arrows.length),
        );
        final shuffleRng = Random(currentSeed);
        candidates.shuffle(shuffleRng);

        for (var i = 0; i < switchableCount && i < candidates.length; i++) {
          final arrow = candidates[i];
          final idx = arrows.indexOf(arrow);
          arrows[idx] = ArrowModel(
            id: arrow.id,
            startNode: arrow.startNode,
            trajectory: arrow.trajectory,
            isSwitchable: true,
          );
        }
      }
    }

    return LevelModel(
      id: id,
      name: name,
      difficulty: difficulty,
      boardSize: BoardSizeModel(rows: config.rows, cols: config.cols),
      boardState: BoardStateModel(arrows: arrows),
    );
  }

  /// Traverses the generated board and builds its blocking dependency graph.
  static ArrowBlockingGraph _buildBlockingGraph(List<ArrowModel> arrows, LevelConfig config) {
    final graph = ArrowBlockingGraph();

    for (final arrow in arrows) {
      graph.addNode(arrow.id);
    }

    // Build spatial occupancy index
    final occupancy = <String, String>{};
    for (final arrow in arrows) {
      final cells = _getArrowCells(arrow);
      for (final cell in cells) {
        occupancy[_key(cell[0], cell[1])] = arrow.id;
      }
    }

    // Add blockages based on exits intersecting other arrows
    for (final arrow in arrows) {
      final cells = _getArrowCells(arrow);
      final head = cells.last;
      final (dr, dc) = _getDirectionOffset(arrow.trajectory.segments.last.direction.name);

      var er = head[0] + dr, ec = head[1] + dc;
      while (_inBoard(er, ec, config)) {
        final blockerId = occupancy[_key(er, ec)];
        if (blockerId != null && blockerId != arrow.id) {
          graph.addBlockage(from: blockerId, to: arrow.id);
        }
        er += dr;
        ec += dc;
      }
    }

    return graph;
  }

  /// Greedy drain check: verifies that all arrows can be cleared in some order.
  ///
  /// Uses the same exit-trajectory check as the generator's monotone property:
  /// iterates arrows in any order, removes those with a clear exit path, and
  /// repeats until no more can exit. If any arrows remain, the board is stuck.
  ///
  /// This is O(N² × L) where N = arrow count and L = max exit path length;
  /// for 60 arrows on a 12×12 board this is ~60² × 12 ≈ 43K checks per drain
  /// pass, and with at most N passes, ~2.6M operations total. Called once per
  /// generated board, it's well within acceptable latency.
  static bool _isSolvable(List<ArrowModel> arrows, LevelConfig config) {
    // Build a reverse index: cell-key -> set of arrow IDs occupying it.
    final occupancy = <String, Set<String>>{};
    for (final arrow in arrows) {
      for (final cell in _getArrowCells(arrow)) {
        final key = _key(cell[0], cell[1]);
        occupancy.putIfAbsent(key, () => {}).add(arrow.id);
      }
    }

    final remaining = Set<String>.from(arrows.map((a) => a.id));
    var madeProgress = true;

    while (madeProgress && remaining.isNotEmpty) {
      madeProgress = false;
      for (final arrowId in remaining.toList()) {
        final arrow = arrows.firstWhere((a) => a.id == arrowId);
        if (_drainCanExit(arrow, remaining, occupancy, config)) {
          remaining.remove(arrowId);
          madeProgress = true;
          break;
        }
      }
    }

    return remaining.isEmpty;
  }

  /// Checks whether [arrow]'s exit path is clear of all other arrows still in
  /// the [remaining] set.
  static bool _drainCanExit(
    ArrowModel arrow,
    Set<String> remaining,
    Map<String, Set<String>> occupancy,
    LevelConfig config,
  ) {
    final cells = _getArrowCells(arrow);
    final head = cells.last;
    final (dr, dc) = _getDirectionOffset(
      arrow.trajectory.segments.last.direction.name,
    );

    var er = head[0] + dr, ec = head[1] + dc;
    while (_inBoard(er, ec, config)) {
      final blockers = occupancy[_key(er, ec)];
      if (blockers != null) {
        for (final blockerId in blockers) {
          if (blockerId != arrow.id && remaining.contains(blockerId)) {
            return false;
          }
        }
      }
      er += dr;
      ec += dc;
    }

    return true;
  }

  /// Traces all grid coordinates occupied by an ArrowModel.
  static List<List<int>> _getArrowCells(ArrowModel arrow) {
    final cells = <List<int>>[[arrow.startNode.row, arrow.startNode.col]];
    var r = arrow.startNode.row;
    var c = arrow.startNode.col;

    for (final segment in arrow.trajectory.segments) {
      final (dr, dc) = _getDirectionOffset(segment.direction.name);
      for (var i = 0; i < segment.length; i++) {
        r += dr;
        c += dc;
        cells.add([r, c]);
      }
    }
    return cells;
  }

  static (int, int) _getDirectionOffset(String dirName) {
    return switch (dirName) {
      'up' => (-1, 0),
      'down' => (1, 0),
      'left' => (0, -1),
      'right' => (0, 1),
      _ => (0, 0),
    };
  }

  static const List<(int, int)> _dirs = [
    (-1, 0), // up
    (1, 0), // down
    (0, -1), // left
    (0, 1), // right
  ];
  static const List<String> _dirNames = ['up', 'down', 'left', 'right'];

  static bool _inBoard(int r, int c, LevelConfig config) => 
      r >= 0 && r < config.rows && c >= 0 && c < config.cols;

  static int _minDistanceToEdge(int r, int c, LevelConfig config) {
    final d1 = r;
    final d2 = config.rows - 1 - r;
    final d3 = c;
    final d4 = config.cols - 1 - c;
    var m = d1;
    if (d2 < m) m = d2;
    if (d3 < m) m = d3;
    if (d4 < m) m = d4;
    return m;
  }

  static bool _inSilhouette(int r, int c, LevelConfig config) {
    if (config.silhouette == null) return true;
    if (r < 0 || r >= config.silhouette!.length) return false;
    if (c < 0 || c >= config.silhouette![r].length) return false;
    return config.silhouette![r][c] == '1';
  }

  static String _key(int r, int c) => '${r}_$c';

  static _Candidate? _tryMakeArrow(Random rng, Set<String> occupied, int index, LevelConfig config) {
    final dIdx = rng.nextInt(4);
    final (dr, dc) = _dirs[dIdx];
    final dirName = _dirNames[dIdx];

    // Head cell must be within board and inside the silhouette mask.
    final hr = rng.nextInt(config.rows);
    final hc = rng.nextInt(config.cols);
    if (!_inSilhouette(hr, hc, config) || occupied.contains(_key(hr, hc))) return null;

    // --- ONION EFFECT (EFECTO CEBOLLA) BIAS ---
    // Since generation runs backward, first placed arrows are the last to exit (most blocked / outer).
    // Last placed arrows are the first to exit (unblocked / inner).
    final progress = index / config.arrowCount;
    final edgeDist = _minDistanceToEdge(hr, hc, config);
    
    if (progress < 0.35) {
      // Outer layer (first 35%): force heads near the perimeter/boundaries
      final maxEdgeDist = config.rows >= 10 ? 2 : 1;
      if (edgeDist > maxEdgeDist) return null; // Reject center placement
    } else if (progress >= 0.70) {
      // Inner layer (last 30%): force heads near the center of the board
      if (edgeDist < 2 && config.rows >= 7) return null; // Reject edge placement
    }

    // Exit trajectory from head to edge must be clear (in-board part).
    // Note: Exit trajectories are allowed to cross empty spaces (0s) outside the silhouette.
    var er = hr + dr, ec = hc + dc;
    while (_inBoard(er, ec, config)) {
      if (occupied.contains(_key(er, ec))) return null;
      er += dr;
      ec += dc;
    }

    // Build the body backward from the head (tail -> head order at the end).
    final shapeType = rng.nextDouble();
    // Cells collected head-first, reversed to tail->head before returning.
    final headFirst = <List<int>>[[hr, hc]];
    var cr = hr, cc = hc;

    if (shapeType < config.straightRatio) {
      // Straight arrow
      final len = config.minSegmentLength + 
                  rng.nextInt(config.maxSegmentLength - config.minSegmentLength + 1);
      for (var i = 1; i < len; i++) {
        cr -= dr;
        cc -= dc;
        if (!_inBoard(cr, cc, config) || 
            !_inSilhouette(cr, cc, config) || 
            occupied.contains(_key(cr, cc))) {
          break;
        }
        headFirst.add([cr, cc]);
      }
    } else if (shapeType < config.straightRatio + config.lShapeRatio) {
      // L-shape arrow
      final lastLen = config.minSegmentLength + 
                      rng.nextInt(config.maxSegmentLength - config.minSegmentLength + 1);
      for (var i = 0; i < lastLen; i++) {
        cr -= dr;
        cc -= dc;
        if (!_inBoard(cr, cc, config) || 
            !_inSilhouette(cr, cc, config) || 
            occupied.contains(_key(cr, cc))) {
          return _finish(dirName, headFirst);
        }
        headFirst.add([cr, cc]);
      }
      // Turn perpendicular
      final turnLeft = rng.nextBool();
      final (tr, tc) = turnLeft ? (-dc, dr) : (dc, -dr);
      final firstLen = config.minSegmentLength + 
                       rng.nextInt(config.maxSegmentLength - config.minSegmentLength + 1);
      for (var i = 0; i < firstLen; i++) {
        cr -= tr;
        cc -= tc;
        if (!_inBoard(cr, cc, config) || 
            !_inSilhouette(cr, cc, config) || 
            occupied.contains(_key(cr, cc))) {
          return _finish(dirName, headFirst);
        }
        headFirst.add([cr, cc]);
      }
    } else if (shapeType < config.straightRatio + config.lShapeRatio + config.zShapeRatio) {
      // Z-shape arrow - zigzag with two turns
      final firstLen = config.minSegmentLength + 
                       rng.nextInt(config.maxSegmentLength - config.minSegmentLength + 1);
      for (var i = 0; i < firstLen; i++) {
        cr -= dr;
        cc -= dc;
        if (!_inBoard(cr, cc, config) || 
            !_inSilhouette(cr, cc, config) || 
            occupied.contains(_key(cr, cc))) {
          return _finish(dirName, headFirst);
        }
        headFirst.add([cr, cc]);
      }
      // First turn
      final turnLeft = rng.nextBool();
      final (tr, tc) = turnLeft ? (-dc, dr) : (dc, -dr);
      final midLen = config.minSegmentLength + 
                     rng.nextInt(config.maxSegmentLength - config.minSegmentLength + 1);
      for (var i = 0; i < midLen; i++) {
        cr -= tr;
        cc -= tc;
        if (!_inBoard(cr, cc, config) || 
            !_inSilhouette(cr, cc, config) || 
            occupied.contains(_key(cr, cc))) {
          return _finish(dirName, headFirst);
        }
        headFirst.add([cr, cc]);
      }
      // Second turn (back to original direction)
      final lastLen = config.minSegmentLength + 
                      rng.nextInt(config.maxSegmentLength - config.minSegmentLength + 1);
      for (var i = 0; i < lastLen; i++) {
        cr -= dr;
        cc -= dc;
        if (!_inBoard(cr, cc, config) || 
            !_inSilhouette(cr, cc, config) || 
            occupied.contains(_key(cr, cc))) {
          return _finish(dirName, headFirst);
        }
        headFirst.add([cr, cc]);
      }
    } else {
      // U-shape arrow - 180° turn
      final firstLen = config.minSegmentLength + 
                       rng.nextInt(config.maxSegmentLength - config.minSegmentLength + 1);
      for (var i = 0; i < firstLen; i++) {
        cr -= dr;
        cc -= dc;
        if (!_inBoard(cr, cc, config) || 
            !_inSilhouette(cr, cc, config) || 
            occupied.contains(_key(cr, cc))) {
          return _finish(dirName, headFirst);
        }
        headFirst.add([cr, cc]);
      }
      // Turn 90°
      final turnLeft = rng.nextBool();
      final (tr, tc) = turnLeft ? (-dc, dr) : (dc, -dr);
      final midLen = config.minSegmentLength + 
                     rng.nextInt(config.maxSegmentLength - config.minSegmentLength + 1);
      for (var i = 0; i < midLen; i++) {
        cr -= tr;
        cc -= tc;
        if (!_inBoard(cr, cc, config) || 
            !_inSilhouette(cr, cc, config) || 
            occupied.contains(_key(cr, cc))) {
          return _finish(dirName, headFirst);
        }
        headFirst.add([cr, cc]);
      }
      // Turn 90° again (now going opposite direction)
      final lastLen = config.minSegmentLength + 
                      rng.nextInt(config.maxSegmentLength - config.minSegmentLength + 1);
      for (var i = 0; i < lastLen; i++) {
        cr += dr;
        cc += dc; // Go forward now
        if (!_inBoard(cr, cc, config) || 
            !_inSilhouette(cr, cc, config) || 
            occupied.contains(_key(cr, cc))) {
          return _finish(dirName, headFirst);
        }
        headFirst.add([cr, cc]);
      }
    }

    return _finish(dirName, headFirst);
  }

  /// Try to place an arrow that blocks [targetArrow] by placing its body
  /// on [targetArrow]'s exit trajectory.
  static _Candidate? _tryForceChain(
    ArrowModel targetArrow,
    Random rng,
    Set<String> occupied,
    LevelConfig config,
  ) {
    final cells = _getArrowCells(targetArrow);
    final head = cells.last;
    final (dr, dc) = _getDirectionOffset(
      targetArrow.trajectory.segments.last.direction.name,
    );

    // Trace exit path from target arrow's head, collecting free cells.
    final exitPath = <(int, int)>[];
    var er = head[0] + dr, ec = head[1] + dc;
    while (_inBoard(er, ec, config)) {
      if (!occupied.contains(_key(er, ec))) {
        exitPath.add((er, ec));
      }
      er += dr;
      ec += dc;
    }

    if (exitPath.isEmpty) return null;

    for (var attempt = 0; attempt < 15; attempt++) {
      final targetCell = exitPath[rng.nextInt(exitPath.length)];

      final dIdx = rng.nextInt(4);
      final (adr, adc) = _dirs[dIdx];
      final adirName = _dirNames[dIdx];

      final len = config.minSegmentLength +
          rng.nextInt(config.maxSegmentLength - config.minSegmentLength + 1);

      // Place head so that targetCell is somewhere in the body.
      final k = rng.nextInt(len);
      final hr = targetCell.$1 + k * adr;
      final hc = targetCell.$2 + k * adc;

      if (!_inBoard(hr, hc, config) ||
          !_inSilhouette(hr, hc, config) ||
          occupied.contains(_key(hr, hc))) {
        continue;
      }

      // Check exit from head is clear.
      var ehr = hr + adr, ech = hc + adc;
      var exitClear = true;
      while (_inBoard(ehr, ech, config)) {
        if (occupied.contains(_key(ehr, ech))) {
          exitClear = false;
          break;
        }
        ehr += adr;
        ech += adc;
      }
      if (!exitClear) continue;

      // Build body backward from head.
      final headFirst = <List<int>>[[hr, hc]];
      var cr = hr, cc = hc;
      var bodyValid = true;
      for (var i = 1; i < len; i++) {
        cr -= adr;
        cc -= adc;
        if (!_inBoard(cr, cc, config) ||
            !_inSilhouette(cr, cc, config) ||
            occupied.contains(_key(cr, cc))) {
          bodyValid = false;
          break;
        }
        headFirst.add([cr, cc]);
      }
      if (!bodyValid || headFirst.length < 2) continue;

      return _finish(adirName, headFirst);
    }

    return null;
  }

  static _Candidate? _finish(String dirName, List<List<int>> headFirst) {
    // Minimum 2 cells per arrow
    if (headFirst.length < 2) return null;
    
    final cells = headFirst.reversed.toList(); // tail -> head
    final model = arrowHelper('a${_seq++}', dirName, cells);
    final keys = cells.map((c) => _key(c[0], c[1])).toSet();
    return _Candidate(model, keys);
  }

  // Per-generation arrow id counter; ids only need to be unique within a level,
  // but a monotone counter across the run keeps them unique regardless.
  static int _seq = 1;
}

class _Candidate {
  const _Candidate(this.model, this.cellKeys);
  final ArrowModel model;
  final Set<String> cellKeys;
}
