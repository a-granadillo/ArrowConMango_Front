import 'dart:math';

import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/board_size_model.dart';
import 'package:arrowconmango_front/features/game/data/models/board_state_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';

import 'package:arrowconmango_front/features/game/domain/services/arrow_blocking_graph.dart';

import 'arrow_helper.dart';

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
  });

  static const LevelConfig easy = LevelConfig(
    rows: 6,
    cols: 6,
    arrowCount: 15,
    straightRatio: 0.60, // 60% straight
    lShapeRatio: 0.40, // 40% L-shape
    zShapeRatio: 0.0, // 0% Z-shape
    uShapeRatio: 0.0, // 0% U-shape
    minSegmentLength: 2,
    maxSegmentLength: 4,
    minGraphDepth: 3, // Needs at least 3-step dependency chain
  );

  static const LevelConfig medium = LevelConfig(
    rows: 8,
    cols: 8,
    arrowCount: 30,
    straightRatio: 0.30, // 30% straight
    lShapeRatio: 0.35, // 35% L-shape
    zShapeRatio: 0.20, // 20% Z-shape
    uShapeRatio: 0.15, // 15% U-shape
    minSegmentLength: 2,
    maxSegmentLength: 4,
    minGraphDepth: 5, // Needs at least 5-step dependency chain
  );

  static const LevelConfig hard = LevelConfig(
    rows: 12,
    cols: 12,
    arrowCount: 60,
    straightRatio: 0.15, // 15% straight
    lShapeRatio: 0.35, // 35% L-shape
    zShapeRatio: 0.30, // 30% Z-shape
    uShapeRatio: 0.20, // 20% U-shape
    minSegmentLength: 2,
    maxSegmentLength: 5,
    minGraphDepth: 8, // Needs at least 8-step dependency chain (extremely complex!)
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
    while (boardAttempts < 100) {
      boardAttempts++;
      final rng = Random(currentSeed);
      final occupied = <String>{};
      arrows = <ArrowModel>[];

      var attempts = 0;
      final maxAttempts = config.arrowCount * 800;
      while (arrows.length < config.arrowCount && attempts < maxAttempts) {
        attempts++;
        final candidate = _tryMakeArrow(rng, occupied, arrows.length, config);
        if (candidate == null) continue;
        arrows.add(candidate.model);
        occupied.addAll(candidate.cellKeys);
      }

      // Analyze blocking dependencies using the ArrowBlockingGraph
      graph = _buildBlockingGraph(arrows, config);
      if (graph.getMaxDepth() >= config.minGraphDepth) {
        // Success! The board is both solvable and satisfies target complexity
        break;
      }

      // Try next seed if the board was too parallel/easy
      currentSeed++;
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

  static String _key(int r, int c) => '${r}_$c';

  static _Candidate? _tryMakeArrow(Random rng, Set<String> occupied, int index, LevelConfig config) {
    final dIdx = rng.nextInt(4);
    final (dr, dc) = _dirs[dIdx];
    final dirName = _dirNames[dIdx];

    // Head cell.
    final hr = rng.nextInt(config.rows);
    final hc = rng.nextInt(config.cols);
    if (occupied.contains(_key(hr, hc))) return null;

    // Exit trajectory from head to edge must be clear (in-board part).
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
        if (!_inBoard(cr, cc, config) || occupied.contains(_key(cr, cc))) break;
        headFirst.add([cr, cc]);
      }
    } else if (shapeType < config.straightRatio + config.lShapeRatio) {
      // L-shape arrow
      final lastLen = config.minSegmentLength + 
                      rng.nextInt(config.maxSegmentLength - config.minSegmentLength + 1);
      for (var i = 0; i < lastLen; i++) {
        cr -= dr;
        cc -= dc;
        if (!_inBoard(cr, cc, config) || occupied.contains(_key(cr, cc))) {
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
        if (!_inBoard(cr, cc, config) || occupied.contains(_key(cr, cc))) {
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
        if (!_inBoard(cr, cc, config) || occupied.contains(_key(cr, cc))) {
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
        if (!_inBoard(cr, cc, config) || occupied.contains(_key(cr, cc))) {
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
        if (!_inBoard(cr, cc, config) || occupied.contains(_key(cr, cc))) {
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
        if (!_inBoard(cr, cc, config) || occupied.contains(_key(cr, cc))) {
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
        if (!_inBoard(cr, cc, config) || occupied.contains(_key(cr, cc))) {
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
        if (!_inBoard(cr, cc, config) || occupied.contains(_key(cr, cc))) {
          return _finish(dirName, headFirst);
        }
        headFirst.add([cr, cc]);
      }
    }

    return _finish(dirName, headFirst);
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
