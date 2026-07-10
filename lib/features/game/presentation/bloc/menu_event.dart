import 'package:equatable/equatable.dart';

/// {@template menu_event}
/// Base class for all events that can be dispatched to the [MenuBloc].
/// {@endtemplate}
sealed class MenuEvent extends Equatable {
  /// {@macro menu_event}
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

/// Requests the list of available levels, combining level count and progress.
final class MenuLevelsRequested extends MenuEvent {
  /// Creates a [MenuLevelsRequested] event.
  const MenuLevelsRequested();
}
