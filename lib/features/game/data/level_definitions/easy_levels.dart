import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/board_state_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';

/// Collection of the 5 easy levels (10-20 arrows each).
class EasyLevels {
  EasyLevels._();

  static final List<LevelModel> all = [
    level1Heart,
    level2Star,
    level3ArrowUp,
    level4House,
    level5Diamond,
  ];

  /// Level 1: Heart silhouette on a 6x7 grid (12 arrows).
  static final LevelModel level1Heart = LevelModel(
    id: 1,
    name: 'Heart',
    difficulty: 'Easy',
    boardState: BoardStateModel(arrows: [
      _arrow('a1', 'right', [(0, 1), (0, 2)]),
      _arrow('a2', 'left', [(0, 5), (0, 4)]),
      _arrow('a3', 'right', [(1, 0), (1, 1), (1, 2)]),
      _arrow('a4', 'down', [(1, 3)]),
      _arrow('a5', 'left', [(1, 6), (1, 5), (1, 4)]),
      _arrow('a6', 'right', [(2, 0), (2, 1), (2, 2)]),
      _arrow('a7', 'down', [(2, 3)]),
      _arrow('a8', 'left', [(2, 6), (2, 5), (2, 4)]),
      _arrow('a9', 'right', [(3, 1), (3, 2), (3, 3)]),
      _arrow('a10', 'left', [(3, 5), (3, 4)]),
      _arrow('a11', 'right', [(4, 2), (4, 3), (4, 4)]),
      _arrow('a12', 'down', [(5, 3)]),
    ]),
  );

  /// Level 2: Star silhouette on a 7x7 grid (19 arrows).
  static final LevelModel level2Star = LevelModel(
    id: 2,
    name: 'Star',
    difficulty: 'Easy',
    boardState: BoardStateModel(arrows: [
      _arrow('a1', 'up', [(0, 2)]),
      _arrow('a2', 'up', [(0, 4)]),
      _arrow('a3', 'right', [(1, 1), (1, 2)]),
      _arrow('a4', 'down', [(1, 3)]),
      _arrow('a5', 'left', [(1, 5), (1, 4)]),
      _arrow('a6', 'right', [(2, 0), (2, 1), (2, 2)]),
      _arrow('a7', 'down', [(2, 3)]),
      _arrow('a8', 'left', [(2, 6), (2, 5), (2, 4)]),
      _arrow('a9', 'right', [(3, 1), (3, 2)]),
      _arrow('a10', 'down', [(3, 3)]),
      _arrow('a11', 'left', [(3, 5), (3, 4)]),
      _arrow('a12', 'right', [(4, 0), (4, 1), (4, 2)]),
      _arrow('a13', 'down', [(4, 3)]),
      _arrow('a14', 'left', [(4, 6), (4, 5), (4, 4)]),
      _arrow('a15', 'right', [(5, 1), (5, 2)]),
      _arrow('a16', 'down', [(5, 3)]),
      _arrow('a17', 'left', [(5, 5), (5, 4)]),
      _arrow('a18', 'down', [(6, 2)]),
      _arrow('a19', 'down', [(6, 4)]),
    ]),
  );

  /// Level 3: Arrow Up silhouette on a 7x7 grid (18 arrows).
  static final LevelModel level3ArrowUp = LevelModel(
    id: 3,
    name: 'Arrow Up',
    difficulty: 'Easy',
    boardState: BoardStateModel(arrows: [
      _arrow('a1', 'up', [(0, 2)]),
      _arrow('a2', 'up', [(0, 3)]),
      _arrow('a3', 'up', [(0, 4)]),
      _arrow('a4', 'up', [(1, 2)]),
      _arrow('a5', 'up', [(1, 3)]),
      _arrow('a6', 'up', [(1, 4)]),
      _arrow('a7', 'up', [(2, 2)]),
      _arrow('a8', 'up', [(2, 3)]),
      _arrow('a9', 'up', [(2, 4)]),
      _arrow('a10', 'up', [(3, 2)]),
      _arrow('a11', 'up', [(3, 3)]),
      _arrow('a12', 'up', [(3, 4)]),
      _arrow('a13', 'right', [(4, 1), (4, 2), (4, 3)]),
      _arrow('a14', 'left', [(4, 5), (4, 4)]),
      _arrow('a15', 'right', [(5, 0), (5, 1), (5, 2)]),
      _arrow('a16', 'down', [(5, 3)]),
      _arrow('a17', 'left', [(5, 6), (5, 5), (5, 4)]),
      _arrow('a18', 'down', [(6, 3)]),
    ]),
  );

  /// Level 4: House silhouette on a 7x7 grid (19 arrows).
  static final LevelModel level4House = LevelModel(
    id: 4,
    name: 'House',
    difficulty: 'Easy',
    boardState: BoardStateModel(arrows: [
      _arrow('a1', 'up', [(0, 3)]),
      _arrow('a2', 'up', [(1, 2)]),
      _arrow('a3', 'up', [(1, 3)]),
      _arrow('a4', 'up', [(1, 4)]),
      _arrow('a5', 'right', [(2, 1), (2, 2), (2, 3)]),
      _arrow('a6', 'up', [(2, 4)]),
      _arrow('a7', 'left', [(2, 5)]),
      _arrow('a8', 'right', [(3, 0), (3, 1), (3, 2)]),
      _arrow('a9', 'down', [(3, 3)]),
      _arrow('a10', 'left', [(3, 6), (3, 5), (3, 4)]),
      _arrow('a11', 'right', [(4, 0)]),
      _arrow('a12', 'right', [(4, 2), (4, 3), (4, 4)]),
      _arrow('a13', 'left', [(4, 6)]),
      _arrow('a14', 'right', [(5, 0)]),
      _arrow('a15', 'right', [(5, 2), (5, 3), (5, 4)]),
      _arrow('a16', 'left', [(5, 6)]),
      _arrow('a17', 'right', [(6, 0), (6, 1), (6, 2)]),
      _arrow('a18', 'up', [(6, 3)]),
      _arrow('a19', 'left', [(6, 6), (6, 5), (6, 4)]),
    ]),
  );

  /// Level 5: Diamond silhouette on a 7x7 grid (12 arrows).
  static final LevelModel level5Diamond = LevelModel(
    id: 5,
    name: 'Diamond',
    difficulty: 'Easy',
    boardState: BoardStateModel(arrows: [
      _arrow('a1', 'up', [(0, 3)]),
      _arrow('a2', 'left', [(1, 2)]),
      _arrow('a3', 'right', [(1, 4)]),
      _arrow('a4', 'left', [(2, 1)]),
      _arrow('a5', 'right', [(2, 5)]),
      _arrow('a6', 'left', [(3, 0)]),
      _arrow('a7', 'right', [(3, 6)]),
      _arrow('a8', 'left', [(4, 1)]),
      _arrow('a9', 'right', [(4, 5)]),
      _arrow('a10', 'left', [(5, 2)]),
      _arrow('a11', 'right', [(5, 4)]),
      _arrow('a12', 'down', [(6, 3)]),
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
