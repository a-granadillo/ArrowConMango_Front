import 'package:arrowconmango_front/features/game/data/models/board_size_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';

import 'board_state_mapper.dart';

/// Converts [LevelModel] to/from [Level].
///
/// **Note:** This mapper is lossy in the `LevelModel → Level` direction.
/// The domain [Level] entity only stores `levelId` and `templateBoard`,
/// so `name` and `difficulty` from the model are not preserved on round-trips.
/// When converting back (`Level → LevelModel`), `name` is derived as
/// `'Level ${levelId}'` and `difficulty` is computed from `Level.difficulty()`.
///
/// `boardSize` is inferred from the occupied nodes when converting from the
/// domain entity; this keeps the domain model free of presentation/persistence
/// details while still producing a complete model.
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
      boardSize: _calculateBoardSize(entity.templateBoard),
      boardState: _boardStateMapper.toModel(entity.templateBoard),
    );
  }

  BoardSizeModel _calculateBoardSize(BoardState boardState) {
    var maxRow = 0;
    var maxCol = 0;
    for (final arrow in boardState.arrows) {
      for (final node in arrow.occupiedNodes) {
        if (node is! Grid2DNodeId) {
          throw ArgumentError(
            'LevelMapper only supports Grid2DNodeId, got ${node.runtimeType}.',
          );
        }
        if (node.row > maxRow) maxRow = node.row;
        if (node.col > maxCol) maxCol = node.col;
      }
    }
    return BoardSizeModel(rows: maxRow + 1, cols: maxCol + 1);
  }
}
