import 'package:equatable/equatable.dart';

import 'board_state.dart';
import 'game_session.dart';

/// A pre-built level definition holding the template [BoardState] and metadata.
///
/// The [templateBoard] serves as the starting configuration.  The
/// [GameSession] clones it to produce the mutable [boardState].
class Level extends Equatable {
  final int levelId;

  /// Human-readable level name (e.g. "Mango Verde"). Optional for backward
  /// compatibility with tests that build a [Level] without one.
  final String name;

  final int rows;

  final int cols;

  final BoardState templateBoard;

  const Level({
    required this.levelId,
    this.name = '',
    required this.rows,
    required this.cols,
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

  /// Creates a new [GameSession] from this level's template board.
  ///
  /// [sessionId] is a unique identifier for the session (e.g., UUID v4).
  /// [startedAtMs] is the timestamp when the session started (epoch milliseconds).
  GameSession startSession({
    required String sessionId,
    required int startedAtMs,
  }) {
    return GameSession(
      sessionId: sessionId,
      boardState: templateBoard,
      startedAtMs: startedAtMs,
    );
  }

  @override
  List<Object?> get props => [levelId, name, rows, cols, templateBoard];

  @override
  String toString() =>
      'Level(id: $levelId, difficulty: ${difficulty()}, board: $templateBoard)';
}
