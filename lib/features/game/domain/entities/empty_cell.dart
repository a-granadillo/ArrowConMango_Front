import 'cell.dart';
import 'direction.dart';
import 'path_step.dart';
import 'position.dart';

/// A passable [Cell] with no arrow — it does not direct movement.
///
/// [rotate] and [executeAction] are no-ops that return an identical copy.
class EmptyCell extends Cell {
  const EmptyCell({
    required super.id,
    required super.position,
    super.isActivated = false,
  }) : super();

  @override
  EmptyCell rotate() => copyWith();

  @override
  PathStep evaluatePath(Direction incomingDirection) {
    // Empty cells allow the path to slide through in the same direction it arrived.
    return PathStep(outcome: PathOutcome.continuePath, nextDirection: incomingDirection);
  }

  @override
  EmptyCell executeAction() => this;

  @override
  EmptyCell copyWith({
    String? id,
    Position? position,
    bool? isActivated,
  }) {
    return EmptyCell(
      id: id ?? this.id,
      position: position ?? this.position,
      isActivated: isActivated ?? this.isActivated,
    );
  }

  @override
  String toString() => 'EmptyCell(id: $id, pos: $position)';
}
