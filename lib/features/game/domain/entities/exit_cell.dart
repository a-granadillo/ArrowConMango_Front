import 'cell.dart';
import 'direction.dart';
import 'path_step.dart';
import 'position.dart';

/// The goal [Cell] — reaching it means the player has solved the level.
///
/// [rotate] and [executeAction] are no-ops that return an identical copy.
class ExitCell extends Cell {
  const ExitCell({
    required super.id,
    required super.position,
    super.isActivated = false,
  }) : super();

  @override
  ExitCell rotate() => copyWith();

  @override
  PathStep evaluatePath(Direction incomingDirection) {
    // Defines a winning condition upon reaching this cell.
    return PathStep(outcome: PathOutcome.exitReached, nextDirection: incomingDirection);
  }

  @override
  ExitCell executeAction() => this;

  @override
  ExitCell copyWith({
    String? id,
    Position? position,
    bool? isActivated,
  }) {
    return ExitCell(
      id: id ?? this.id,
      position: position ?? this.position,
      isActivated: isActivated ?? this.isActivated,
    );
  }

  @override
  String toString() => 'ExitCell(id: $id, pos: $position)';
}
