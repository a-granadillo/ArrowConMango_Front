import 'board_state_model.dart';

/// Data model for levels (DTO for serialization).
///
/// This is a simple, serializable representation of a level.
/// Use [Level] for domain logic.
class LevelModel {
  final int levelId;
  final BoardStateModel templateBoard;

  const LevelModel({
    required this.levelId,
    required this.templateBoard,
  });

  /// Creates a [LevelModel] from a JSON map.
  factory LevelModel.fromMap(Map<String, dynamic> map) {
    return LevelModel(
      levelId: map['levelId'] as int,
      templateBoard: BoardStateModel.fromMap(
        map['templateBoard'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'levelId': levelId,
      'templateBoard': templateBoard.toMap(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelModel &&
          runtimeType == other.runtimeType &&
          levelId == other.levelId &&
          templateBoard == other.templateBoard;

  @override
  int get hashCode => levelId.hashCode ^ templateBoard.hashCode;

  @override
  String toString() =>
      'LevelModel(levelId: $levelId, arrows: ${templateBoard.arrows.length})';
}
