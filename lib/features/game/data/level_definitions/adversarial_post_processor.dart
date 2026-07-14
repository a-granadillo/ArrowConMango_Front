import 'dart:math';

import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';

import 'arrow_helper.dart';

/// After the board is generated, injects decoy arrows that create the
/// visual illusion of blocking critical dependency chains.
///
/// These arrows are always solvable (monotone property preserved) but
/// increase cognitive load by appearing to sit in front of deep chains.
class AdversarialPostProcessor {
  AdversarialPostProcessor._();

  static const int _maxAttemptsPerDecoy = 30;

  /// Injects up to [maxDecoys] decoy arrows near deep-chain cells.
  static List<ArrowModel> injectDecoys({
    required List<ArrowModel> existingArrows,
    required Set<String> currentOccupied,
    required List<String>? silhouette,
    required int rows,
    required int cols,
    required Random rng,
    int maxDecoys = 3,
  }) {
    if (existingArrows.isEmpty || maxDecoys <= 0) return [];

    final occupied = Set<String>.from(currentOccupied);
    final decoys = <ArrowModel>[];

    // Deep arrows: the last ~30% of insertion order are deeper in the chain.
    final deepArrowCount = (existingArrows.length * 0.3).ceil();
    final deepArrows =
        existingArrows.skip(existingArrows.length - deepArrowCount).toList();

    for (var attempt = 0;
        attempt < maxDecoys * _maxAttemptsPerDecoy &&
            decoys.length < maxDecoys;
        attempt++) {
      final anchor = deepArrows[rng.nextInt(deepArrows.length)];
      final anchorCells = _getArrowCells(anchor);

      // Find cells in this arrow that are near the edge (distance <= 2).
      final edgeNearCells = anchorCells.where((c) {
        final dist = _minDistanceToEdge(c[0], c[1], rows, cols);
        return dist <= 2 && dist >= 0;
      }).toList();

      if (edgeNearCells.isEmpty) continue;

      final anchorCell = edgeNearCells[rng.nextInt(edgeNearCells.length)];

      // Direction TOWARD the nearest edge.
      final decoyDir = _nearestEdgeDirection(anchorCell[0], anchorCell[1], rows, cols);
      if (decoyDir == null) continue;
      final (dr, dc) = _getDirectionOffset(decoyDir);

      // Build cells from tail (near anchor) toward head (near edge).
      // cells[i] is at anchorCell + (i+1)*dr/dc.
      final len = 2 + rng.nextInt(2); // 2 or 3 cells
      final cells = <List<int>>[];
      var cr = anchorCell[0] + dr;
      var cc = anchorCell[1] + dc;
      var valid = true;

      for (var i = 0; i < len; i++) {
        if (cr < 0 || cr >= rows || cc < 0 || cc >= cols) {
          valid = false;
          break;
        }
        if (occupied.contains('${cr}_$cc')) {
          valid = false;
          break;
        }
        if (!_inSilhouette(cr, cc, silhouette)) {
          valid = false;
          break;
        }
        cells.add([cr, cc]);
        cr += dr;
        cc += dc;
      }

      if (!valid || cells.length < 2) continue;

      // cells is in tail→head order: cells[0] nearest anchor, cells[last] nearest edge.
      // Exit direction is decoyDir (toward edge, away from center).
      final head = cells.last;

      // Verify exit from head is clear all the way to the board edge.
      var exitClear = true;
      var er = head[0] + dr, ec = head[1] + dc;
      while (er >= 0 && er < rows && ec >= 0 && ec < cols) {
        if (occupied.contains('${er}_$ec')) {
          exitClear = false;
          break;
        }
        er += dr;
        ec += dc;
      }
      if (!exitClear) continue;

      // Create the arrow. cells is already tail→head, matching arrowHelper expectations.
      final id = 'd${decoys.length}';
      final model = arrowHelper(id, decoyDir, cells);

      decoys.add(model);
      for (final cell in cells) {
        occupied.add('${cell[0]}_${cell[1]}');
      }
    }

    return decoys;
  }

  static bool _inSilhouette(int r, int c, List<String>? silhouette) {
    if (silhouette == null) return true;
    if (r < 0 || r >= silhouette.length) return false;
    if (c < 0 || c >= silhouette[r].length) return false;
    return silhouette[r][c] == '1';
  }

  /// Returns the direction name toward the nearest board edge, or null if equidistant.
  static String? _nearestEdgeDirection(int r, int c, int rows, int cols) {
    final dists = [r, rows - 1 - r, c, cols - 1 - c];
    final min = dists.reduce((a, b) => a < b ? a : b);
    final idx = dists.indexOf(min);
    return switch (idx) {
      0 => 'up',
      1 => 'down',
      2 => 'left',
      3 => 'right',
      _ => null,
    };
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

  static int _minDistanceToEdge(int r, int c, int rows, int cols) {
    final d1 = r;
    final d2 = rows - 1 - r;
    final d3 = c;
    final d4 = cols - 1 - c;
    var m = d1;
    if (d2 < m) m = d2;
    if (d3 < m) m = d3;
    if (d4 < m) m = d4;
    return m;
  }

  static List<List<int>> _getArrowCells(ArrowModel arrow) {
    final cells = <List<int>>[
      [arrow.startNode.row, arrow.startNode.col]
    ];
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
}
