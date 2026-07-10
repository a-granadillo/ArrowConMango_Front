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

/// Requests the persisted [AppProgress] to be loaded.
final class ProgressRequested extends ProgressEvent {
  /// Creates a [ProgressRequested] event.
  const ProgressRequested();
}

/// Requests unlocking the level that follows [currentLevelId].
///
/// The next level's unlock is persisted as part of handling this event.
final class ProgressLevelUnlocked extends ProgressEvent {
  /// Creates a [ProgressLevelUnlocked] event.
  const ProgressLevelUnlocked({required this.currentLevelId});

  /// Identifier of the level that was just completed.
  final int currentLevelId;

  @override
  List<Object?> get props => [currentLevelId];
}

/// Requests persisting [progress] as-is.
final class ProgressSaved extends ProgressEvent {
  /// Creates a [ProgressSaved] event.
  const ProgressSaved({required this.progress});

  /// Progress to persist.
  final AppProgress progress;

  @override
  List<Object?> get props => [progress];
}
