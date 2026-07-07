import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/board_state_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';

/// Collection of the 5 medium levels (21-40 arrows each).
class MediumLevels {
  MediumLevels._();

  static final List<LevelModel> all = [
    level6Mango,
    level7Car,
    level8Spaceship,
    level9Tree,
    level10Butterfly,
  ];

  /// Level 6: Mango silhouette on a 9x9 grid (21 arrows).
  static final LevelModel level6Mango = LevelModel(
    id: 6,
    name: 'Mango',
    difficulty: 'Medium',
    boardState: BoardStateModel(arrows: [
      _arrow('a1', 'up', [(0, 5)]),
      _arrow('a2', 'right', [(1, 4), (1, 5)]),
      _arrow('a3', 'left', [(1, 6)]),
      _arrow('a4', 'right', [(2, 3), (2, 4), (2, 5)]),
      _arrow('a5', 'left', [(2, 7), (2, 6)]),
      _arrow('a6', 'right', [(3, 2), (3, 3), (3, 4)]),
      _arrow('a7', 'right', [(3, 5), (3, 6), (3, 7)]),
      _arrow('a8', 'right', [(3, 8)]),
      _arrow('a9', 'right', [(4, 1), (4, 2), (4, 3)]),
      _arrow('a10', 'right', [(4, 4), (4, 5), (4, 6)]),
      _arrow('a11', 'right', [(4, 7), (4, 8)]),
      _arrow('a12', 'right', [(5, 1), (5, 2), (5, 3)]),
      _arrow('a13', 'right', [(5, 4), (5, 5), (5, 6)]),
      _arrow('a14', 'right', [(5, 7), (5, 8)]),
      _arrow('a15', 'right', [(6, 2), (6, 3), (6, 4)]),
      _arrow('a16', 'right', [(6, 5), (6, 6), (6, 7)]),
      _arrow('a17', 'right', [(6, 8)]),
      _arrow('a18', 'right', [(7, 3), (7, 4), (7, 5)]),
      _arrow('a19', 'left', [(7, 7), (7, 6)]),
      _arrow('a20', 'right', [(8, 4), (8, 5)]),
      _arrow('a21', 'left', [(8, 6)]),
    ]),
  );

  /// Level 7: Car silhouette on a 9x9 grid (26 arrows).
  static final LevelModel level7Car = LevelModel(
    id: 7,
    name: 'Car',
    difficulty: 'Medium',
    boardState: BoardStateModel(arrows: [
      _arrow('a1', 'right', [(0, 2), (0, 3)]),
      _arrow('a2', 'left', [(0, 5), (0, 4)]),
      _arrow('a3', 'right', [(1, 1), (1, 2), (1, 3)]),
      _arrow('a4', 'down', [(1, 4)]),
      _arrow('a5', 'left', [(1, 7), (1, 6), (1, 5)]),
      _arrow('a6', 'right', [(2, 0), (2, 1), (2, 2)]),
      _arrow('a7', 'right', [(2, 3), (2, 4), (2, 5)]),
      _arrow('a8', 'left', [(2, 8), (2, 7), (2, 6)]),
      _arrow('a9', 'right', [(3, 0), (3, 1), (3, 2)]),
      _arrow('a10', 'right', [(3, 3), (3, 4), (3, 5)]),
      _arrow('a11', 'left', [(3, 8), (3, 7), (3, 6)]),
      _arrow('a12', 'right', [(4, 0), (4, 1), (4, 2)]),
      _arrow('a13', 'right', [(4, 3), (4, 4), (4, 5)]),
      _arrow('a14', 'left', [(4, 8), (4, 7), (4, 6)]),
      _arrow('a15', 'right', [(5, 0), (5, 1), (5, 2)]),
      _arrow('a16', 'right', [(5, 3), (5, 4), (5, 5)]),
      _arrow('a17', 'left', [(5, 8), (5, 7), (5, 6)]),
      _arrow('a18', 'right', [(6, 1), (6, 2)]),
      _arrow('a19', 'left', [(6, 7), (6, 6)]),
      _arrow('a20', 'right', [(7, 1), (7, 2)]),
      _arrow('a21', 'left', [(7, 7), (7, 6)]),
      _arrow('a22', 'right', [(8, 0), (8, 1), (8, 2)]),
      _arrow('a23', 'down', [(8, 3)]),
      _arrow('a24', 'down', [(8, 4)]),
      _arrow('a25', 'right', [(8, 5)]),
      _arrow('a26', 'left', [(8, 8), (8, 7), (8, 6)]),
    ]),
  );

  /// Level 8: Spaceship silhouette on a 9x9 grid (25 arrows).
  static final LevelModel level8Spaceship = LevelModel(
    id: 8,
    name: 'Spaceship',
    difficulty: 'Medium',
    boardState: BoardStateModel(arrows: [
      _arrow('a1', 'up', [(0, 4)]),
      _arrow('a2', 'up', [(1, 3)]),
      _arrow('a3', 'up', [(1, 4)]),
      _arrow('a4', 'up', [(1, 5)]),
      _arrow('a5', 'right', [(2, 2), (2, 3)]),
      _arrow('a6', 'down', [(2, 4)]),
      _arrow('a7', 'left', [(2, 6), (2, 5)]),
      _arrow('a8', 'right', [(3, 1), (3, 2), (3, 3)]),
      _arrow('a9', 'down', [(3, 4)]),
      _arrow('a10', 'left', [(3, 7), (3, 6), (3, 5)]),
      _arrow('a11', 'right', [(4, 1), (4, 2), (4, 3)]),
      _arrow('a12', 'down', [(4, 4)]),
      _arrow('a13', 'left', [(4, 7), (4, 6), (4, 5)]),
      _arrow('a14', 'right', [(5, 0), (5, 1), (5, 2)]),
      _arrow('a15', 'down', [(5, 3)]),
      _arrow('a16', 'down', [(5, 4)]),
      _arrow('a17', 'down', [(5, 5)]),
      _arrow('a18', 'left', [(5, 8), (5, 7), (5, 6)]),
      _arrow('a19', 'right', [(6, 0), (6, 1), (6, 2)]),
      _arrow('a20', 'right', [(6, 3), (6, 4), (6, 5)]),
      _arrow('a21', 'left', [(6, 8), (6, 7), (6, 6)]),
      _arrow('a22', 'right', [(7, 0), (7, 1), (7, 2)]),
      _arrow('a23', 'left', [(7, 8), (7, 7), (7, 6)]),
      _arrow('a24', 'right', [(8, 1), (8, 2)]),
      _arrow('a25', 'left', [(8, 7), (8, 6)]),
    ]),
  );

  /// Level 9: Tree silhouette on a 9x9 grid (23 arrows).
  static final LevelModel level9Tree = LevelModel(
    id: 9,
    name: 'Tree',
    difficulty: 'Medium',
    boardState: BoardStateModel(arrows: [
      _arrow('a1', 'right', [(0, 2), (0, 3), (0, 4)]),
      _arrow('a2', 'left', [(0, 6), (0, 5)]),
      _arrow('a3', 'right', [(1, 1), (1, 2), (1, 3)]),
      _arrow('a4', 'down', [(1, 4)]),
      _arrow('a5', 'left', [(1, 7), (1, 6), (1, 5)]),
      _arrow('a6', 'right', [(2, 0), (2, 1), (2, 2)]),
      _arrow('a7', 'right', [(2, 3), (2, 4), (2, 5)]),
      _arrow('a8', 'left', [(2, 8), (2, 7), (2, 6)]),
      _arrow('a9', 'right', [(3, 0), (3, 1), (3, 2)]),
      _arrow('a10', 'right', [(3, 3), (3, 4), (3, 5)]),
      _arrow('a11', 'left', [(3, 8), (3, 7), (3, 6)]),
      _arrow('a12', 'right', [(4, 1), (4, 2), (4, 3)]),
      _arrow('a13', 'down', [(4, 4)]),
      _arrow('a14', 'left', [(4, 7), (4, 6), (4, 5)]),
      _arrow('a15', 'right', [(5, 2), (5, 3), (5, 4)]),
      _arrow('a16', 'left', [(5, 6), (5, 5)]),
      _arrow('a17', 'right', [(6, 3), (6, 4)]),
      _arrow('a18', 'left', [(6, 5)]),
      _arrow('a19', 'right', [(7, 3), (7, 4)]),
      _arrow('a20', 'left', [(7, 5)]),
      _arrow('a21', 'right', [(8, 2), (8, 3)]),
      _arrow('a22', 'down', [(8, 4)]),
      _arrow('a23', 'left', [(8, 6), (8, 5)]),
    ]),
  );

  /// Level 10: Butterfly silhouette on a 9x9 grid (29 arrows).
  static final LevelModel level10Butterfly = LevelModel(
    id: 10,
    name: 'Butterfly',
    difficulty: 'Medium',
    boardState: BoardStateModel(arrows: [
      _arrow('a1', 'up', [(0, 4)]),
      _arrow('a2', 'right', [(1, 3), (1, 4)]),
      _arrow('a3', 'left', [(1, 5)]),
      _arrow('a4', 'right', [(2, 2), (2, 3)]),
      _arrow('a5', 'down', [(2, 4)]),
      _arrow('a6', 'left', [(2, 6), (2, 5)]),
      _arrow('a7', 'right', [(3, 0), (3, 1), (3, 2)]),
      _arrow('a8', 'right', [(3, 3), (3, 4), (3, 5)]),
      _arrow('a9', 'left', [(3, 8), (3, 7), (3, 6)]),
      _arrow('a10', 'right', [(4, 0), (4, 1), (4, 2)]),
      _arrow('a11', 'right', [(4, 3), (4, 4), (4, 5)]),
      _arrow('a12', 'left', [(4, 8), (4, 7), (4, 6)]),
      _arrow('a13', 'down', [(5, 0)]),
      _arrow('a14', 'down', [(5, 1)]),
      _arrow('a15', 'down', [(5, 2)]),
      _arrow('a16', 'down', [(5, 3)]),
      _arrow('a17', 'down', [(5, 4)]),
      _arrow('a18', 'down', [(5, 5)]),
      _arrow('a19', 'down', [(5, 6)]),
      _arrow('a20', 'down', [(5, 7)]),
      _arrow('a21', 'down', [(5, 8)]),
      _arrow('a22', 'right', [(6, 0), (6, 1), (6, 2)]),
      _arrow('a23', 'right', [(6, 3), (6, 4), (6, 5)]),
      _arrow('a24', 'left', [(6, 8), (6, 7), (6, 6)]),
      _arrow('a25', 'right', [(7, 1), (7, 2), (7, 3)]),
      _arrow('a26', 'left', [(7, 6), (7, 5), (7, 4)]),
      _arrow('a27', 'left', [(7, 7)]),
      _arrow('a28', 'right', [(8, 2), (8, 3), (8, 4)]),
      _arrow('a29', 'left', [(8, 6), (8, 5)]),
    ]),
  );

}

ArrowModel _arrow(String id, String direction, List<List<int>> cells) {
  return ArrowModel(
    id: id,
    direction: direction,
    nodes: cells.map((c) => NodeModel(row: c[0], col: c[1])).toList(),
  );
}
