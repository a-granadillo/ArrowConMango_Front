import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:equatable/equatable.dart';

/// {@template progress_state}
/// Base class for all states emitted by the [ProgressBloc].
/// {@endtemplate}
sealed class ProgressState extends Equatable {
  /// {@macro progress_state}
  const ProgressState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any progress has been requested.
final class ProgressInitial extends ProgressState {
  /// Creates a [ProgressInitial] state.
  const ProgressInitial();
}

/// The progress is being loaded, unlocked, or saved.
final class ProgressLoading extends ProgressState {
  /// Creates a [ProgressLoading] state.
  const ProgressLoading();
}

/// The most recent progress operation completed successfully.
final class ProgressLoaded extends ProgressState {
  /// Creates a [ProgressLoaded] state.
  const ProgressLoaded({required this.progress});

  /// Current progress snapshot.
  final AppProgress progress;

  @override
  List<Object?> get props => [progress];
}

/// The most recent progress operation failed.
final class ProgressFailure extends ProgressState {
  /// Creates a [ProgressFailure] state.
  const ProgressFailure({required this.message});

  /// Human-readable description of the error.
  final String message;

  @override
  List<Object?> get props => [message];
}
