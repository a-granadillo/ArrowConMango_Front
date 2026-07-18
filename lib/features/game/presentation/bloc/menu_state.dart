import 'package:arrowconmango_front/features/game/application/dtos/level_summary.dart';
import 'package:equatable/equatable.dart';

/// {@template menu_state}
/// Base class for all states emitted by the [MenuBloc].
/// {@endtemplate}
sealed class MenuState extends Equatable {
  /// {@macro menu_state}
  const MenuState();

  @override
  List<Object?> get props => [];
}

/// Initial state before the level list has been loaded.
final class MenuInitial extends MenuState {
  /// Creates a [MenuInitial] state.
  const MenuInitial();
}

/// The level list is being loaded.
final class MenuLoading extends MenuState {
  /// Creates a [MenuLoading] state.
  const MenuLoading();
}

/// The level list has been successfully loaded.
final class MenuLoaded extends MenuState {
  /// Creates a [MenuLoaded] state.
  const MenuLoaded({required this.levels});

  /// List of level summaries to display.
  final List<LevelSummary> levels;

  @override
  List<Object?> get props => [levels];
}

/// An error occurred while loading the level list.
final class MenuError extends MenuState {
  /// Creates a [MenuError] state.
  const MenuError({required this.message});

  /// Human-readable description of the error.
  final String message;

  @override
  List<Object?> get props => [message];
}
