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

/// Requests the level list to be loaded, showing a full loading indicator.
final class MenuLevelsRequested extends MenuEvent {
  /// Creates a [MenuLevelsRequested] event.
  const MenuLevelsRequested();
}

/// Requests a silent refresh of the level list without showing a loading
/// indicator.
final class MenuLevelsRefreshed extends MenuEvent {
  /// Creates a [MenuLevelsRefreshed] event.
  const MenuLevelsRefreshed();
}
