import 'package:arrowconmango_front/features/game/data/models/board_size_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';

import 'board_state_mapper.dart';

class LevelMapper {
  final BoardStateMapper _boardStateMapper;

  const LevelMapper(this._boardStateMapper);

  Level toEntity(LevelModel model) {
    return Level(
      levelId: model.id,
      name: model.name,
      rows: model.boardSize.rows,
      cols: model.boardSize.cols,
      templateBoard: _boardStateMapper.toEntity(model.boardState),
    );
  }

  LevelModel toModel(Level entity) {
    return LevelModel(
      id: entity.levelId,
      name: entity.name.isNotEmpty ? entity.name : 'Level ${entity.levelId}',
      difficulty: entity.difficulty(),
      boardSize: BoardSizeModel(rows: entity.rows, cols: entity.cols),
      boardState: _boardStateMapper.toModel(entity.templateBoard),
    );
  }
}
