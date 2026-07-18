import 'package:arrowconmango_front/features/game/data/models/board_state_model.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:injectable/injectable.dart';

import 'arrow_mapper.dart';

/// Converts [BoardStateModel] to/from [BoardState].
@lazySingleton
class BoardStateMapper {
  final ArrowMapper _arrowMapper;

  const BoardStateMapper(this._arrowMapper);

  BoardState toEntity(BoardStateModel model) {
    return BoardState(
      arrows: model.arrows.map(_arrowMapper.toEntity).toList(),
    );
  }

  BoardStateModel toModel(BoardState entity) {
    return BoardStateModel(
      arrows: entity.arrows.map(_arrowMapper.toModel).toList(),
    );
  }
}
