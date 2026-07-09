import 'package:equatable/equatable.dart';

import 'board_size_model.dart';
import 'board_state_model.dart';

/// Serializable representation of a level definition.
class LevelModel extends Equatable {
  final int id;
  final String name;
  final String difficulty;
  final BoardSizeModel boardSize;
  final BoardStateModel boardState;

  const LevelModel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.boardSize,
    required this.boardState,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'] as int,
      name: json['name'] as String,
      difficulty: json['difficulty'] as String,
      boardSize: BoardSizeModel.fromJson(
        json['boardSize'] as Map<String, dynamic>,
      ),
      boardState: BoardStateModel.fromJson(
        json['boardState'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'difficulty': difficulty,
      'boardSize': boardSize.toJson(),
      'boardState': boardState.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, name, difficulty, boardSize, boardState];
}
