import 'package:equatable/equatable.dart';

import 'board.dart';
import 'cell.dart';
import 'command_history.dart';
import 'move_command.dart';
import 'position.dart';

/// Represents an active game in progress.
///
/// Holds the current [activeBoard] and a [CommandHistory] for undo support.
/// All mutating operations return **new** [GameSession] instances so that
/// the BLoC layer correctly detects state transitions via [Equatable].
class GameSession extends Equatable {
  /// Unique identifier for this session (e.g. UUID v4).
  final String sessionId;

  /// The current board state during play.
  final Board activeBoard;

  /// Ordered history of applied moves (for undo).
  final CommandHistory history;

  /// Number of moves applied so far.
  final int moveCount;

  /// Timestamp (epoch milliseconds) when the session started.
  final int startedAtMs;

  const GameSession({
    required this.sessionId,
    required this.activeBoard,
    this.history = const CommandHistory(),
    this.moveCount = 0,
    required this.startedAtMs,
  });

  /// Applies [cmd] by rotating its target cell and replacing it on the board.
  ///
  /// Returns a new [GameSession] reflecting the updated board, incremented
  /// move count, and appended command history.
  GameSession applyMove(MoveCommand cmd) {
    final rotatedCell = cmd.execute();
    final newBoard = activeBoard.replaceCell(rotatedCell);
    final newHistory = history.push(cmd);

    return _copy(
      activeBoard: newBoard,
      history: newHistory,
      moveCount: moveCount + 1,
    );
  }

  /// Reverts the most recent move, if any.
  ///
  /// Returns a new [GameSession] with the previous board state restored.
GameSession undoLastMove() {
    final result = history.pop();
    if (result == null) return this;

    final (newHistory, lastCmd) = result;
    final originalCell = lastCmd.undo();
    final newBoard = activeBoard.replaceCell(originalCell);

    return _copy(
      activeBoard: newBoard,
      history: newHistory,
      moveCount: moveCount - 1,
    );
  }

  /// Returns the [Cell] at [position] on the [activeBoard], or `null`.
  Cell? getCellAt(Position position) => activeBoard.getCellAt(position);

  /// Whether the path from [start] to the exit is currently clear.
  bool isPathClear(Position start) => activeBoard.isPathClear(start);

  /// Private copy helper — retains [sessionId] and [startedAtMs].
  GameSession _copy({
    Board? activeBoard,
    CommandHistory? history,
    int? moveCount,
  }) {
    return GameSession(
      sessionId: sessionId,
      activeBoard: activeBoard ?? this.activeBoard,
      history: history ?? this.history,
      moveCount: moveCount ?? this.moveCount,
      startedAtMs: startedAtMs,
    );
  }

  @override
  List<Object?> get props => [
        sessionId,
        activeBoard,
        history,
        moveCount,
        startedAtMs,
      ];

  @override
  String toString() =>
      'GameSession(id: $sessionId, moves: $moveCount, board: $activeBoard)';
}
