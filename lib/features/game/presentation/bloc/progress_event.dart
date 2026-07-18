import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:equatable/equatable.dart';

/// {@template progress_event}
/// Base class for all events that can be dispatched to the [ProgressBloc].
/// {@endtemplate}
sealed class ProgressEvent extends Equatable {
  /// {@macro progress_event}
  const ProgressEvent();

  @override
  List<Object?> get props => [];
}

/// Requests the player's persisted progress to be loaded.
final class ProgressLoadStarted extends ProgressEvent {
  /// Creates a [ProgressLoadStarted] event.
  const ProgressLoadStarted();
}

/// Notifies that the player has completed a level and the next one should be
/// unlocked.
final class ProgressLevelCompleted extends ProgressEvent {
  /// Creates a [ProgressLevelCompleted] event.
  const ProgressLevelCompleted({
    required this.currentLevelId,
    required this.moves,
    required this.elapsedSeconds,
  });

  /// Identifier of the level that was just completed.
  final int currentLevelId;

  /// Number of moves used to complete the level, submitted to the
  /// leaderboard alongside [elapsedSeconds].
  final int moves;

  /// Time taken to complete the level, in seconds.
  final int elapsedSeconds;

  @override
  List<Object?> get props => [currentLevelId, moves, elapsedSeconds];
}

/// Replaces the current progress with an externally provided value.
final class ProgressUpdatedExternally extends ProgressEvent {
  /// Creates a [ProgressUpdatedExternally] event.
  const ProgressUpdatedExternally({required this.progress});

  /// New progress value to expose.
  final AppProgress progress;

  @override
  List<Object?> get props => [progress];
}
