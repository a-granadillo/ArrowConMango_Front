import 'cell.dart';
import 'direction.dart';
import 'path_step.dart';
import 'position.dart';

/// A solid [Cell] that blocks all movement.
///
/// [rotate] and [executeAction] are no-ops that return an identical copy.
class WallCell extends Cell {
  const WallCell({
    required super.id,
    required super.position,
    super.isActivated = false,
  }) : super();

  @override
  WallCell rotate() => copyWith();

  @override
  PathStep evaluatePath(Direction incomingDirection) {
    // Walls completely block the path.
    return PathStep(outcome: PathOutcome.blocked, nextDirection: incomingDirection);
  }

  @override
  WallCell executeAction() => this;

  @override
  WallCell copyWith({
    String? id,
    Position? position,
    bool? isActivated,
  }) {
    return WallCell(
      id: id ?? this.id,
      position: position ?? this.position,
      isActivated: isActivated ?? this.isActivated,
    );
  }

  @override
  String toString() => 'WallCell(id: $id, pos: $position)';
}
