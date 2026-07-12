import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/command_history.dart';
import 'package:arrowconmango_front/features/game/domain/entities/score.dart';
import 'package:equatable/equatable.dart';

/// Reasons why a level can end in defeat.
enum DefeatReason {
  /// The player has no remaining moves.
  noMovesAvailable,

  /// The available time for the level has expired.
  timeExpired,
}

/// {@template game_state}
/// Base class for all states emitted by the [GameBloc].
/// {@endtemplate}
sealed class GameState extends Equatable {
  /// {@macro game_state}
  const GameState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any level has been loaded.
final class GameInitial extends GameState {
  /// Creates a [GameInitial] state.
  const GameInitial();
}

/// The game is loading a level definition and preparing the session.
final class GameLoading extends GameState {
  /// Creates a [GameLoading] state.
  const GameLoading({required this.levelId});

  /// Identifier of the level being loaded.
  final int levelId;

  @override
  List<Object?> get props => [levelId];
}

/// The player is actively playing a level.
final class GamePlaying extends GameState {
  /// Creates a [GamePlaying] state.
  const GamePlaying({
    required this.levelId,
    this.levelName = '',
    required this.difficulty,
    this.rows = 8,
    this.cols = 8,
    required this.boardState,
    required this.moveCount,
    required this.history,
    required this.score,
    required this.arrowsRemaining,
    required this.elapsedSeconds,
    required this.startedAtMs,
  });

  /// Identifier of the current level.
  final int levelId;

  /// Human-readable name of the current level (e.g. "Mango Verde").
  final String levelName;

  /// Difficulty label of the current level.
  final String difficulty;

  /// Number of rows on the board.
  final int rows;

  /// Number of columns on the board.
  final int cols;

  /// Current state of the board.
  final BoardState boardState;

  /// Number of moves performed so far.
  final int moveCount;

  /// Ordered history of applied moves that backs the undo feature.
  ///
  /// This is the source of truth for the UI; the BLoC rebuilds the
  /// domain session from this history on demand.
  final CommandHistory history;

  /// Whether there is at least one move that can be undone.
  bool get canUndo => history.canUndo;

  /// Current score for the active session.
  final Score score;

  /// Number of arrows that have not exited the board yet.
  final int arrowsRemaining;

  /// Elapsed time since the level started, in seconds.
  final int elapsedSeconds;

  /// Timestamp in milliseconds when the level started.
  final int startedAtMs;

  @override
  List<Object?> get props => [
        levelId,
        levelName,
        difficulty,
        rows,
        cols,
        boardState,
        moveCount,
        history,
        score,
        arrowsRemaining,
        elapsedSeconds,
        startedAtMs,
      ];
}

/// The player has successfully completed the level.
final class GameVictory extends GameState {
  /// Creates a [GameVictory] state.
  const GameVictory({
    required this.levelId,
    required this.score,
    required this.moveCount,
    required this.elapsedSeconds,
  });

  /// Identifier of the completed level.
  final int levelId;

  /// Final score for the completed level.
  final Score score;

  /// Total number of moves used to complete the level.
  final int moveCount;

  /// Total elapsed time in seconds until victory.
  final int elapsedSeconds;

  @override
  List<Object?> get props => [levelId, score, moveCount, elapsedSeconds];
}

/// The player failed to complete the level.
final class GameDefeat extends GameState {
  /// Creates a [GameDefeat] state.
  const GameDefeat({
    required this.levelId,
    required this.reason,
    required this.moveCount,
    required this.elapsedSeconds,
  });

  /// Identifier of the failed level.
  final int levelId;

  /// Reason for the defeat.
  final DefeatReason reason;

  /// Total number of moves performed before defeat.
  final int moveCount;

  /// Total elapsed time in seconds until defeat.
  final int elapsedSeconds;

  @override
  List<Object?> get props => [levelId, reason, moveCount, elapsedSeconds];
}

/// An error occurred while loading or running the game.
final class GameError extends GameState {
  /// Creates a [GameError] state.
  const GameError({
    required this.message,
    this.levelId,
  });

  /// Human-readable description of the error.
  final String message;

  /// Optional identifier of the level that caused the error.
  final int? levelId;

  @override
  List<Object?> get props => [message, levelId];
}
