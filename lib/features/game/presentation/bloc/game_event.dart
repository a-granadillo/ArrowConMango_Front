import 'package:equatable/equatable.dart';

import '../../domain/entities/level.dart';

/// {@template game_event}
/// Base class for all events that can be dispatched to the [GameBloc].
/// {@endtemplate}
sealed class GameEvent extends Equatable {
  /// {@macro game_event}
  const GameEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the level identified by [levelId] into the game session.
final class LoadLevel extends GameEvent {
  /// Creates a [LoadLevel] event.
  const LoadLevel({required this.levelId});

  /// Identifier of the level to load.
  final int levelId;

  @override
  List<Object?> get props => [levelId];
}

/// Loads an already-built [Level] directly, bypassing [ILevelRepository] —
/// for levels that don't live in the local catalogue (community levels
/// fetched from the backend, or a draft being test-played in the editor).
final class LoadExternalLevel extends GameEvent {
  const LoadExternalLevel({required this.level, this.timeLimitSeconds});

  final Level level;

  /// Overrides the bloc's default time limit — a community level's own
  /// [LevelRules.timeLimitSeconds], when set.
  final int? timeLimitSeconds;

  @override
  List<Object?> get props => [level, timeLimitSeconds];
}

/// Requests the exit of the arrow identified by [arrowId].
final class TriggerArrowExit extends GameEvent {
  /// Creates a [TriggerArrowExit] event.
  const TriggerArrowExit({required this.arrowId});

  /// Identifier of the arrow that should try to exit.
  final String arrowId;

  @override
  List<Object?> get props => [arrowId];
}

/// Requests to undo the last player move.
final class UndoMove extends GameEvent {
  /// Creates an [UndoMove] event.
  const UndoMove();
}

/// Periodic tick used to update elapsed time and timers.
final class Tick extends GameEvent {
  /// Creates a [Tick] event.
  const Tick({required this.nowMs});

  /// Current timestamp in milliseconds.
  final int nowMs;

  @override
  List<Object?> get props => [nowMs];
}

/// Requests to retry the current level from its initial state.
final class RetryLevel extends GameEvent {
  /// Creates a [RetryLevel] event.
  const RetryLevel();
}

/// Requests to load the next level in endless mode.
final class NextEndlessLevel extends GameEvent {
  /// Creates a [NextEndlessLevel] event.
  const NextEndlessLevel();
}

/// Requests to rotate the arrow identified by [arrowId] 90° clockwise.
final class RotateArrow extends GameEvent {
  /// Creates a [RotateArrow] event.
  const RotateArrow({required this.arrowId});

  /// Identifier of the arrow to rotate.
  final String arrowId;

  @override
  List<Object?> get props => [arrowId];
}
