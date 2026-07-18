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

/// Initial state before any progress has been loaded.
final class ProgressInitial extends ProgressState {
  /// Creates a [ProgressInitial] state.
  const ProgressInitial();
}

/// Progress is being loaded or persisted.
final class ProgressLoading extends ProgressState {
  /// Creates a [ProgressLoading] state.
  const ProgressLoading();
}

/// Progress has been successfully loaded or updated.
final class ProgressLoaded extends ProgressState {
  /// Creates a [ProgressLoaded] state.
  const ProgressLoaded({required this.progress});

  /// Current player progress.
  final AppProgress progress;

  @override
  List<Object?> get props => [progress];
}

/// An error occurred while handling progress.
final class ProgressError extends ProgressState {
  /// Creates a [ProgressError] state.
  const ProgressError({required this.message});

  /// Human-readable description of the error.
  final String message;

  @override
  List<Object?> get props => [message];
}
