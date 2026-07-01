import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';

import 'board_state_mapper.dart';

/// Converts [LevelModel] to/from [Level].
class LevelMapper {
  final BoardStateMapper _boardStateMapper;

  const LevelMapper(this._boardStateMapper);

  Level toEntity(LevelModel model) {
    return Level(
      levelId: model.id,
      templateBoard: _boardStateMapper.toEntity(model.boardState),
    );
  }

  LevelModel toModel(Level entity) {
    return LevelModel(
      id: entity.levelId,
      name: 'Level ${entity.levelId}',
      difficulty: entity.difficulty(),
      boardState: _boardStateMapper.toModel(entity.templateBoard),
    );
  }
}
