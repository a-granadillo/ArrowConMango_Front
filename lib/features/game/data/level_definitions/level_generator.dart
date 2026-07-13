import 'dart:math';

import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/board_size_model.dart';
import 'package:arrowconmango_front/features/game/data/models/board_state_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';

import 'arrow_helper.dart';

/// Deterministic, **provably-solvable** level generator in the design's style
/// (9 cols × 12 rows, thin arrows with occasional 90° bends).
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

  static const int rows = 12;
  static const int cols = 9;

  /// Builds a level with [arrowCount] arrows using [seed] for reproducibility.
  static LevelModel generate({
    required int id,
    required String name,
    required String difficulty,
    required int arrowCount,
    required int seed,
  }) {
    final rng = Random(seed);
    final occupied = <String>{};
    final arrows = <ArrowModel>[];

    var attempts = 0;
    final maxAttempts = arrowCount * 800; // Increased from 400 for denser levels
    while (arrows.length < arrowCount && attempts < maxAttempts) {
      attempts++;
      final candidate = _tryMakeArrow(rng, occupied, arrows.length);
      if (candidate == null) continue;
      arrows.add(candidate.model);
      occupied.addAll(candidate.cellKeys);
    }

    return LevelModel(
      id: id,
      name: name,
      difficulty: difficulty,
      boardSize: const BoardSizeModel(rows: rows, cols: cols),
      boardState: BoardStateModel(arrows: arrows),
    );
  }

  static const List<(int, int)> _dirs = [
    (-1, 0), // up
    (1, 0), // down
    (0, -1), // left
    (0, 1), // right
  ];
  static const List<String> _dirNames = ['up', 'down', 'left', 'right'];

  static bool _inBoard(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

  static String _key(int r, int c) => '${r}_$c';

  static _Candidate? _tryMakeArrow(Random rng, Set<String> occupied, int index) {
    final dIdx = rng.nextInt(4);
    final (dr, dc) = _dirs[dIdx];
    final dirName = _dirNames[dIdx];

    // Head cell.
    final hr = rng.nextInt(rows);
    final hc = rng.nextInt(cols);
    if (occupied.contains(_key(hr, hc))) return null;

    // Exit trajectory from head to edge must be clear (in-board part).
    var er = hr + dr, ec = hc + dc;
    while (_inBoard(er, ec)) {
      if (occupied.contains(_key(er, ec))) return null;
      er += dr;
      ec += dc;
    }

    // Build the body backward from the head (tail -> head order at the end).
    final bend = rng.nextDouble() < 0.25; // Reduced from 0.35 for longer straight arrows
    // Cells collected head-first, reversed to tail->head before returning.
    final headFirst = <List<int>>[[hr, hc]];
    var cr = hr, cc = hc;

    if (!bend) {
      final len = 2 + rng.nextInt(4); // 2..5 cells (longer arrows)
      for (var i = 1; i < len; i++) {
        cr -= dr;
        cc -= dc;
        if (!_inBoard(cr, cc) || occupied.contains(_key(cr, cc))) break;
        headFirst.add([cr, cc]);
      }
    } else {
      // Last segment (along the head direction), then a perpendicular turn.
      final lastLen = 2 + rng.nextInt(3); // 2..4 cells behind the head along -d
      for (var i = 0; i < lastLen; i++) {
        cr -= dr;
        cc -= dc;
        if (!_inBoard(cr, cc) || occupied.contains(_key(cr, cc))) {
          return _finish(dirName, headFirst); // fall back to what we have
        }
        headFirst.add([cr, cc]);
      }
      // Turn perpendicular.
      final turnLeft = rng.nextBool();
      // Perpendicular unit: rotate (dr,dc) by ±90°.
      final (tr, tc) = turnLeft ? (-dc, dr) : (dc, -dr);
      final firstLen = 2 + rng.nextInt(3); // 2..4 cells in perpendicular direction
      for (var i = 0; i < firstLen; i++) {
        cr -= tr;
        cc -= tc;
        if (!_inBoard(cr, cc) || occupied.contains(_key(cr, cc))) break;
        headFirst.add([cr, cc]);
      }
    }

    return _finish(dirName, headFirst);
  }

  static _Candidate _finish(String dirName, List<List<int>> headFirst) {
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
