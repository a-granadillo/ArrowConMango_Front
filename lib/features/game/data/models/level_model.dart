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
    final boardState = BoardStateModel.fromJson(
      json['boardState'] as Map<String, dynamic>,
    );
    
    // Handle missing boardSize (backward compatibility with old schema)
    BoardSizeModel boardSize;
    if (json.containsKey('boardSize')) {
      boardSize = BoardSizeModel.fromJson(
        json['boardSize'] as Map<String, dynamic>,
      );
    } else {
      // Infer from board state for legacy data
      boardSize = _inferBoardSize(boardState);
    }
    
    return LevelModel(
      id: json['id'] as int,
      name: json['name'] as String,
      difficulty: json['difficulty'] as String,
      boardSize: boardSize,
      boardState: boardState,
    );
  }
  
  /// Infers board size from arrow positions (for backward compatibility).
  static BoardSizeModel _inferBoardSize(BoardStateModel boardState) {
    var maxRow = 0;
    var maxCol = 0;
    
    for (final arrow in boardState.arrows) {
      for (final node in arrow.nodes) {
        if (node.row > maxRow) maxRow = node.row;
        if (node.col > maxCol) maxCol = node.col;
      }
    }
    
    // Default to 1x1 if no arrows (edge case)
    return BoardSizeModel(
      rows: maxRow > 0 ? maxRow + 1 : 1,
      cols: maxCol > 0 ? maxCol + 1 : 1,
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
