import 'cell.dart';

/// Encapsulates a single cell rotation as a reified object (Command pattern).
///
/// Stores the cell **before** the move so that [execute] can produce the
/// rotated version and [undo] can restore the original.
///
/// This class is **stateless** — [execute] and [undo] are pure functions
/// that return new [Cell] instances without mutating internal state.
class MoveCommand {
  /// The cell as it existed before this command was applied.
  final Cell cell;

  const MoveCommand(this.cell);

  /// Returns the cell after applying the rotation.
  Cell execute() => cell.executeAction();

  /// Returns the original, pre-rotation cell (undo effect).
  Cell undo() => cell;

  @override
  String toString() => 'MoveCommand(cell: ${cell.id}@${cell.position})';
}
