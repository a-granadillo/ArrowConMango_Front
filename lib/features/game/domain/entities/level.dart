import 'package:equatable/equatable.dart';

import 'board_state.dart';

/// A pre-built level definition holding the template [BoardState] and metadata.
///
/// The [templateBoard] serves as the starting configuration.  The
/// [GameSession] clones it to produce the mutable [boardState].
class Level extends Equatable {
  /// Unique numeric identifier for this level.
  final int levelId;

  /// The board template from which game sessions are initialised.
  final BoardState templateBoard;

  // ignore: prefer_const_constructors_in_immutables
  Level({
    required this.levelId,
    required this.templateBoard,
  });

  /// Returns a human-readable difficulty label based on [levelId].
  ///
  /// - 1-5  → Easy
  /// - 6-10 → Medium
  /// - 11+  → Hard
  String difficulty() {
    if (levelId <= 5) return 'Easy';
    if (levelId <= 10) return 'Medium';
    return 'Hard';
  }

  @override
  List<Object?> get props => [levelId, templateBoard];

  @override
  String toString() =>
      'Level(id: $levelId, difficulty: ${difficulty()}, board: $templateBoard)';
}
