import 'package:arrowconmango_front/features/game/data/models/board_size_model.dart';
import 'package:arrowconmango_front/features/game/data/models/board_state_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';

import 'arrow_helper.dart';

class EasyLevels {
  EasyLevels._();

  static final List<LevelModel> all = [
    level1Heart,
    level2Star,
    level3ArrowUp,
    level4House,
    level5Diamond,
  ];

  static final LevelModel level1Heart = LevelModel(
    id: 1,
    name: 'Heart',
    difficulty: 'Easy',
    boardSize: BoardSizeModel(rows: 6, cols: 7),
    boardState: BoardStateModel(arrows: [
      arrowHelper('a1', 'right', [[0, 1], [0, 2]]),
      arrowHelper('a2', 'left', [[0, 5], [0, 4]]),
      arrowHelper('a3', 'right', [[1, 0], [1, 1], [1, 2]]),
      arrowHelper('a4', 'down', [[1, 3]]),
      arrowHelper('a5', 'left', [[1, 6], [1, 5], [1, 4]]),
      arrowHelper('a6', 'right', [[2, 0], [2, 1], [2, 2]]),
      arrowHelper('a7', 'down', [[2, 3]]),
      arrowHelper('a8', 'left', [[2, 6], [2, 5], [2, 4]]),
      arrowHelper('a9', 'right', [[3, 1], [3, 2], [3, 3]]),
      arrowHelper('a10', 'left', [[3, 5], [3, 4]]),
      arrowHelper('a11', 'right', [[4, 2], [4, 3], [4, 4]]),
      arrowHelper('a12', 'down', [[5, 3]]),
    ]),
  );

  static final LevelModel level2Star = LevelModel(
    id: 2,
    name: 'Star',
    difficulty: 'Easy',
    boardSize: BoardSizeModel(rows: 7, cols: 7),
    boardState: BoardStateModel(arrows: [
      arrowHelper('a1', 'up', [[0, 2]]),
      arrowHelper('a2', 'up', [[0, 4]]),
      arrowHelper('a3', 'right', [[1, 1], [1, 2]]),
      arrowHelper('a4', 'down', [[1, 3]]),
      arrowHelper('a5', 'left', [[1, 5], [1, 4]]),
      arrowHelper('a6', 'right', [[2, 0], [2, 1], [2, 2]]),
      arrowHelper('a7', 'down', [[2, 3]]),
      arrowHelper('a8', 'left', [[2, 6], [2, 5], [2, 4]]),
      arrowHelper('a9', 'right', [[3, 1], [3, 2]]),
      arrowHelper('a10', 'down', [[3, 3]]),
      arrowHelper('a11', 'left', [[3, 5], [3, 4]]),
      arrowHelper('a12', 'right', [[4, 0], [4, 1], [4, 2]]),
      arrowHelper('a13', 'down', [[4, 3]]),
      arrowHelper('a14', 'left', [[4, 6], [4, 5], [4, 4]]),
      arrowHelper('a15', 'right', [[5, 1], [5, 2]]),
      arrowHelper('a16', 'down', [[5, 3]]),
      arrowHelper('a17', 'left', [[5, 5], [5, 4]]),
      arrowHelper('a18', 'down', [[6, 2]]),
      arrowHelper('a19', 'down', [[6, 4]]),
    ]),
  );

  static final LevelModel level3ArrowUp = LevelModel(
    id: 3,
    name: 'Arrow Up',
    difficulty: 'Easy',
    boardSize: BoardSizeModel(rows: 7, cols: 7),
    boardState: BoardStateModel(arrows: [
      arrowHelper('a1', 'up', [[0, 2]]),
      arrowHelper('a2', 'up', [[0, 3]]),
      arrowHelper('a3', 'up', [[0, 4]]),
      arrowHelper('a4', 'up', [[1, 2]]),
      arrowHelper('a5', 'up', [[1, 3]]),
      arrowHelper('a6', 'up', [[1, 4]]),
      arrowHelper('a7', 'up', [[2, 2]]),
      arrowHelper('a8', 'up', [[2, 3]]),
      arrowHelper('a9', 'up', [[2, 4]]),
      arrowHelper('a10', 'up', [[3, 2]]),
      arrowHelper('a11', 'up', [[3, 3]]),
      arrowHelper('a12', 'up', [[3, 4]]),
      arrowHelper('a13', 'right', [[4, 1], [4, 2], [4, 3]]),
      arrowHelper('a14', 'left', [[4, 5], [4, 4]]),
      arrowHelper('a15', 'right', [[5, 0], [5, 1], [5, 2]]),
      arrowHelper('a16', 'down', [[5, 3]]),
      arrowHelper('a17', 'left', [[5, 6], [5, 5], [5, 4]]),
      arrowHelper('a18', 'down', [[6, 3]]),
    ]),
  );

  static final LevelModel level4House = LevelModel(
    id: 4,
    name: 'House',
    difficulty: 'Easy',
    boardSize: BoardSizeModel(rows: 7, cols: 7),
    boardState: BoardStateModel(arrows: [
      arrowHelper('a1', 'up', [[0, 3]]),
      arrowHelper('a2', 'up', [[1, 2]]),
      arrowHelper('a3', 'up', [[1, 3]]),
      arrowHelper('a4', 'up', [[1, 4]]),
      arrowHelper('a5', 'right', [[2, 1], [2, 2], [2, 3]]),
      arrowHelper('a6', 'up', [[2, 4]]),
      arrowHelper('a7', 'left', [[2, 5]]),
      arrowHelper('a8', 'right', [[3, 0], [3, 1], [3, 2]]),
      arrowHelper('a9', 'down', [[3, 3]]),
      arrowHelper('a10', 'left', [[3, 6], [3, 5], [3, 4]]),
      arrowHelper('a11', 'right', [[4, 0]]),
      arrowHelper('a12', 'right', [[4, 2], [4, 3], [4, 4]]),
      arrowHelper('a13', 'left', [[4, 6]]),
      arrowHelper('a14', 'right', [[5, 0]]),
      arrowHelper('a15', 'right', [[5, 2], [5, 3], [5, 4]]),
      arrowHelper('a16', 'left', [[5, 6]]),
      arrowHelper('a17', 'right', [[6, 0], [6, 1], [6, 2]]),
      arrowHelper('a18', 'up', [[6, 3]]),
      arrowHelper('a19', 'left', [[6, 6], [6, 5], [6, 4]]),
    ]),
  );

  static final LevelModel level5Diamond = LevelModel(
    id: 5,
    name: 'Diamond',
    difficulty: 'Easy',
    boardSize: BoardSizeModel(rows: 7, cols: 7),
    boardState: BoardStateModel(arrows: [
      arrowHelper('a1', 'up', [[0, 3]]),
      arrowHelper('a2', 'left', [[1, 2]]),
      arrowHelper('a3', 'right', [[1, 4]]),
      arrowHelper('a4', 'left', [[2, 1]]),
      arrowHelper('a5', 'right', [[2, 5]]),
      arrowHelper('a6', 'left', [[3, 0]]),
      arrowHelper('a7', 'right', [[3, 6]]),
      arrowHelper('a8', 'left', [[4, 1]]),
      arrowHelper('a9', 'right', [[4, 5]]),
      arrowHelper('a10', 'left', [[5, 2]]),
      arrowHelper('a11', 'right', [[5, 4]]),
      arrowHelper('a12', 'down', [[6, 3]]),
    ]),
  );
}
