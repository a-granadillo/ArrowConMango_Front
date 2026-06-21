import 'package:equatable/equatable.dart';

import '../errors/arrow_not_found_failure.dart';
import 'arrow_entity.dart';
import 'board_state.dart';
import 'command_history.dart';
import 'move_command.dart';

/// Represents an active game in progress.
///
/// Holds the current [boardState] and a [CommandHistory] for undo support.
/// All mutating operations return **new** [GameSession] instances so that
/// the BLoC layer correctly detects state transitions via [Equatable].
class GameSession extends Equatable {
  /// Unique identifier for this session (e.g. UUID v4).
  final String sessionId;

  /// The current board state during play.
  final BoardState boardState;

  /// Ordered history of applied moves (for undo).
  final CommandHistory history;

  /// Number of moves applied so far.
  final int moveCount;

  /// Timestamp (epoch milliseconds) when the session started.
  final int startedAtMs;

  /// Whether the player has won the level.
  ///
  /// Victory condition: all arrows have exited the board (board is empty).
  bool get isVictory => boardState.isEmpty;

  /// Returns the elapsed time in seconds since the session started.
  ///
  /// [nowMs] is the current timestamp in epoch milliseconds.
  /// Returns 0 if [nowMs] is before [startedAtMs] (clock skew protection).
  int elapsedSeconds(int nowMs) {
    final elapsedMs = nowMs - startedAtMs;
    if (elapsedMs < 0) return 0;
    return elapsedMs ~/ 1000;
  }

  // ignore: prefer_const_constructors_in_immutables
  GameSession({
    required this.sessionId,
    required this.boardState,
    this.history = const CommandHistory(),
    this.moveCount = 0,
    required this.startedAtMs,
  });

  /// Records that [arrow] exited the board.
  ///
  /// Returns a new [GameSession] reflecting the updated board, incremented
  /// move count, and appended command history.
  ///
  /// Throws [ArrowNotFoundFailure] if [arrow] is not present in the current board.
  GameSession afterArrowExit(ArrowEntity arrow) {
    if (boardState.getArrowById(arrow.id) == null) {
      throw ArrowNotFoundFailure(arrowId: arrow.id);
    }

    final cmd = ArrowExitCommand(
      exitedArrow: arrow,
      previousState: boardState,
    );
    return _copy(
      boardState: boardState.withoutArrow(arrow),
      history: history.push(cmd),
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
    return _copy(
      boardState: lastCmd.previousState,
      history: newHistory,
      moveCount: moveCount - 1,
    );
  }

  /// Private copy helper — retains [sessionId] and [startedAtMs].
  GameSession _copy({
    BoardState? boardState,
    CommandHistory? history,
    int? moveCount,
  }) {
    return GameSession(
      sessionId: sessionId,
      boardState: boardState ?? this.boardState,
      history: history ?? this.history,
      moveCount: moveCount ?? this.moveCount,
      startedAtMs: startedAtMs,
    );
  }

  @override
  List<Object?> get props => [
        sessionId,
        boardState,
        history,
        moveCount,
        startedAtMs,
      ];

  @override
  String toString() =>
      'GameSession(id: $sessionId, moves: $moveCount, board: $boardState)';
}
