import 'dart:math';

import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';

import 'arrow_helper.dart';

/// A single arrow definition within a pattern template (cell offsets from origin).
class PatternArrowDef {
  final List<(int, int)> cellOffsets;
  final String direction;

  const PatternArrowDef({
    required this.cellOffsets,
    required this.direction,
  });
}

/// Result from placing a pattern template.
class PlacedPattern {
  final List<ArrowModel> arrows;
  final Set<String> cellKeys;

  const PlacedPattern({
    required this.arrows,
    required this.cellKeys,
  });
}

/// Pre-designed interlocking arrow templates that create guaranteed dependency chains.
///
/// Each template is a set of arrows defined as cell offsets from the template origin.
/// When placed, arrows are converted to ArrowModel via arrowHelper.
class PatternPlacer {
  PatternPlacer._();

  /// ChainLink3: A→B→C chain (depth 3, bounding box 4×4).
  ///
  /// ```
  /// A: (0,0)→(0,1)→(0,2) head, direction 'right' → exit hits B at (0,3)
  /// B: (0,3)→(1,3)→(2,3) head, direction 'down'  → exit hits C at (3,3)
  /// C: (3,3)→(3,2)→(3,1) head, direction 'left'   → exit goes off board
  /// ```
  static List<PatternArrowDef> get chainLink3 => [
        PatternArrowDef(
          cellOffsets: [(0, 0), (0, 1), (0, 2)],
          direction: 'right',
        ),
        PatternArrowDef(
          cellOffsets: [(0, 3), (1, 3), (2, 3)],
          direction: 'down',
        ),
        PatternArrowDef(
          cellOffsets: [(3, 3), (3, 2), (3, 1)],
          direction: 'left',
        ),
      ];

  /// DoubleUInterlock: A→B chain (depth 2, bounding box 4×5).
  ///
  /// ```
  /// A: (0,0)→(0,1)→(0,2)→(1,2)→(2,2) head, direction 'down' → exit hits B at (3,2)
  /// B: (3,2)→(3,3)→(3,4)→(2,4)→(1,4) head, direction 'up'   → exit goes off board
  /// ```
  static List<PatternArrowDef> get doubleUInterlock => [
        PatternArrowDef(
          cellOffsets: [(0, 0), (0, 1), (0, 2), (1, 2), (2, 2)],
          direction: 'down',
        ),
        PatternArrowDef(
          cellOffsets: [(3, 2), (3, 3), (3, 4), (2, 4), (1, 4)],
          direction: 'up',
        ),
      ];

  /// SpiralLock: A→B→C→D chain (depth 4, bounding box 5×4).
  ///
  /// FIXED: Original D's exit (up from (1,0)) hit A at (0,0), creating a
  /// cycle. Now D is an L-shaped arrow whose exit goes right, clear of all
  /// other pattern arrows.
  ///
  /// ```
  /// A: (0,0)→(0,1)→(0,2) head, 'right' → exit hits B at (0,3)
  /// B: (0,3)→(1,3)→(2,3) head, 'down'  → exit hits C at (3,3)
  /// C: (3,3)→(3,2)→(3,1) head, 'left'  → exit hits D at (3,0)
  /// D: (3,0)→(4,0)→(4,1) head, 'right' → exit (4,2) is clear of all pattern bodies
  /// ```
  static List<PatternArrowDef> get spiralLock => [
        PatternArrowDef(
          cellOffsets: [(0, 0), (0, 1), (0, 2)],
          direction: 'right',
        ),
        PatternArrowDef(
          cellOffsets: [(0, 3), (1, 3), (2, 3)],
          direction: 'down',
        ),
        PatternArrowDef(
          cellOffsets: [(3, 3), (3, 2), (3, 1)],
          direction: 'left',
        ),
        PatternArrowDef(
          cellOffsets: [(3, 0), (4, 0), (4, 1)],
          direction: 'right',
        ),
      ];

  static Map<String, List<PatternArrowDef>> get templates => {
        'ChainLink3': chainLink3,
        'DoubleUInterlock': doubleUInterlock,
        'SpiralLock': spiralLock,
      };

  static int _boundingBoxRows(List<PatternArrowDef> arrows) {
    var maxR = 0;
    for (final arrow in arrows) {
      for (final (r, _) in arrow.cellOffsets) {
        if (r > maxR) maxR = r;
      }
    }
    return maxR + 1;
  }

  static int _boundingBoxCols(List<PatternArrowDef> arrows) {
    var maxC = 0;
    for (final arrow in arrows) {
      for (final (_, c) in arrow.cellOffsets) {
        if (c > maxC) maxC = c;
      }
    }
    return maxC + 1;
  }

  static bool _inSilhouette(int r, int c, List<String>? silhouette) {
    if (silhouette == null) return true;
    if (r < 0 || r >= silhouette.length) return false;
    if (c < 0 || c >= silhouette[r].length) return false;
    return silhouette[r][c] == '1';
  }

  static String _key(int r, int c) => '${r}_$c';

  /// Try to place a specific template at a random valid position within the board/silhouette.
  /// Returns null if no valid position found.
  static PlacedPattern? tryPlaceTemplate({
    required String templateName,
    required List<String>? silhouette,
    required int rows,
    required int cols,
    required Set<String> currentOccupied,
    required Random rng,
    required int arrowIdOffset,
  }) {
    final template = templates[templateName];
    if (template == null) return null;

    final bbRows = _boundingBoxRows(template);
    final bbCols = _boundingBoxCols(template);

    final validOrigins = <(int, int)>[];
    for (var originR = 0; originR <= rows - bbRows; originR++) {
      for (var originC = 0; originC <= cols - bbCols; originC++) {
        if (_canPlaceAt(template, originR, originC, silhouette, currentOccupied)) {
          validOrigins.add((originR, originC));
        }
      }
    }

    if (validOrigins.isEmpty) return null;

    final (originR, originC) = validOrigins[rng.nextInt(validOrigins.length)];
    return _placeAt(template, originR, originC, arrowIdOffset);
  }

  static bool _canPlaceAt(
    List<PatternArrowDef> template,
    int originR,
    int originC,
    List<String>? silhouette,
    Set<String> currentOccupied,
  ) {
    final cells = <String>{};
    for (final arrow in template) {
      for (final (r, c) in arrow.cellOffsets) {
        final absR = originR + r;
        final absC = originC + c;
        final key = _key(absR, absC);
        if (currentOccupied.contains(key) || cells.contains(key)) return false;
        if (!_inSilhouette(absR, absC, silhouette)) return false;
        cells.add(key);
      }
    }
    return true;
  }

  static PlacedPattern _placeAt(
    List<PatternArrowDef> template,
    int originR,
    int originC,
    int arrowIdOffset,
  ) {
    final arrows = <ArrowModel>[];
    final allKeys = <String>{};

    for (var i = 0; i < template.length; i++) {
      final def = template[i];
      final cells = def.cellOffsets
          .map((rc) => [originR + rc.$1, originC + rc.$2])
          .toList();
      final id = 'p${arrowIdOffset + i}';
      final model = arrowHelper(id, def.direction, cells);
      arrows.add(model);
      allKeys.addAll(cells.map((c) => _key(c[0], c[1])));
    }

    return PlacedPattern(arrows: arrows, cellKeys: allKeys);
  }

  /// Place patterns appropriate for the difficulty level.
  /// Returns the placed arrows and updated occupied set.
  static (List<ArrowModel>, Set<String>) placeForDifficulty({
    required Map<String, int> patternCounts,
    required List<String>? silhouette,
    required int rows,
    required int cols,
    required Set<String> occupied,
    required Random rng,
    required int startArrowId,
  }) {
    if (patternCounts.isEmpty) return ([], occupied);

    final arrows = <ArrowModel>[];
    final allOccupied = Set<String>.from(occupied);
    var nextId = startArrowId;

    for (final entry in patternCounts.entries) {
      final name = entry.key;
      final count = entry.value;
      for (var i = 0; i < count; i++) {
        final placed = tryPlaceTemplate(
          templateName: name,
          silhouette: silhouette,
          rows: rows,
          cols: cols,
          currentOccupied: allOccupied,
          rng: rng,
          arrowIdOffset: nextId,
        );
        if (placed != null) {
          arrows.addAll(placed.arrows);
          allOccupied.addAll(placed.cellKeys);
          nextId += placed.arrows.length;
        }
      }
    }

    return (arrows, allOccupied);
  }
}
