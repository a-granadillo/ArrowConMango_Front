import 'package:equatable/equatable.dart';

import 'arrow_entity.dart';
import 'board_state.dart';
import 'direction.dart';

/// Encapsulates a player action for undo/redo support (Command pattern).
///
/// In the redesigned domain, the primary action is "trigger arrow exit",
/// not "rotate cell". The command stores the pre-action state so it
/// can be perfectly reversed.
sealed class MoveCommand extends Equatable {
  /// The board state BEFORE this command was applied.
  BoardState get previousState;
}

/// Command: player triggered an arrow to exit the board.
class ArrowExitCommand extends MoveCommand {
  final ArrowEntity exitedArrow;
  @override
  final BoardState previousState;

  ArrowExitCommand({
    required this.exitedArrow,
    required this.previousState,
  });

  @override
  List<Object?> get props => [exitedArrow, previousState];
}

/// Command: player rotated an arrow's direction (for levels that allow it).
class ArrowRotateCommand extends MoveCommand {
  final String arrowId;
  final Direction previousDirection;
  @override
  final BoardState previousState;

  ArrowRotateCommand({
    required this.arrowId,
    required this.previousDirection,
    required this.previousState,
  });

  @override
  List<Object?> get props => [arrowId, previousDirection, previousState];
}
