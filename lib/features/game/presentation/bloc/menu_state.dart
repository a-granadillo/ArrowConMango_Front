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

/// Initial state before the level list has been requested.
final class MenuInitial extends MenuState {
  /// Creates a [MenuInitial] state.
  const MenuInitial();
}

/// The level list is being loaded.
final class MenuLoading extends MenuState {
  /// Creates a [MenuLoading] state.
  const MenuLoading();
}

/// The level list was loaded successfully.
final class MenuLevelsLoaded extends MenuState {
  /// Creates a [MenuLevelsLoaded] state.
  const MenuLevelsLoaded({required this.levels});

  /// Summary of every level, including its unlocked status.
  final List<LevelSummary> levels;

  @override
  List<Object?> get props => [levels];
}

/// Loading the level list failed.
final class MenuLoadFailure extends MenuState {
  /// Creates a [MenuLoadFailure] state.
  const MenuLoadFailure({required this.message});

  /// Human-readable description of the error.
  final String message;

  @override
  List<Object?> get props => [message];
}
