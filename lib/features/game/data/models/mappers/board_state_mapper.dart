import '../../domain/entities/board_state.dart';
import '../models/board_state_model.dart';
import 'arrow_mapper.dart';

/// Mapper for converting between [BoardState] and [BoardStateModel].
///
/// Handles the conversion of domain entities to data models for serialization
/// and vice versa.
class BoardStateMapper {
  /// Converts a [BoardState] to a [BoardStateModel].
  static BoardStateModel toModel(BoardState entity) {
    return BoardStateModel(
      arrows: entity.arrows.map((arrow) => ArrowMapper.toModel(arrow)).toList(),
    );
  }

  /// Converts a [BoardStateModel] to a [BoardState].
  static BoardState toEntity(BoardStateModel model) {
    return BoardState(
      arrows: model.arrows.map((arrow) => ArrowMapper.toEntity(arrow)).toList(),
    );
  }
}
