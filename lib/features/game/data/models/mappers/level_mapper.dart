import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'board_state_mapper.dart';

/// Mapper for converting between [Level] and [LevelModel].
///
/// Handles the conversion of domain entities to data models for serialization
/// and vice versa.
class LevelMapper {
  /// Converts a [Level] to a [LevelModel].
  static LevelModel toModel(Level entity) {
    return LevelModel(
      levelId: entity.levelId,
      templateBoard: BoardStateMapper.toModel(entity.templateBoard),
    );
  }

  /// Converts a [LevelModel] to a [Level].
  static Level toEntity(LevelModel model) {
    return Level(
      levelId: model.levelId,
      templateBoard: BoardStateMapper.toEntity(model.templateBoard),
    );
  }
}
