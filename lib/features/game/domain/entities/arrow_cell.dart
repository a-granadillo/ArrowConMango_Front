import 'cell.dart';
import 'direction.dart';
import 'path_step.dart';
import 'position.dart';

/// A [Cell] that points in one of the four cardinal [Direction]s.
///
/// Rotating an arrow cell advances its direction 90° clockwise
/// (up → right → down → left → up).
///
/// **Equality**: two [ArrowCell]s are value-equal when they share the same
/// [id], [position], [isActivated], and [direction].
class ArrowCell extends Cell {
  /// The cardinal direction this arrow currently points to.
  final Direction direction;

  const ArrowCell({
    required super.id,
    required super.position,
    super.isActivated = false,
    required this.direction,
  }) : super();

  /// The grid position this arrow leads to — one step from [position]
  /// in the current [direction].
  Position nextPosition() => position.move(direction);

  /// Returns a new [ArrowCell] with [direction] rotated 90° clockwise.
  @override
  ArrowCell rotate() {
    final nextIndex = (direction.index + 1) % Direction.values.length;
    return copyWith(direction: Direction.values[nextIndex]);
  }

  @override
  PathStep evaluatePath(Direction incomingDirection) {
    // Arrow cells force the path context to use their own direction.
    return PathStep(outcome: PathOutcome.continuePath, nextDirection: direction);
  }

  @override
  ArrowCell executeAction() => rotate();

  /// Returns a new [ArrowCell] with the specified fields replaced.
  @override
  ArrowCell copyWith({
    String? id,
    Position? position,
    bool? isActivated,
    Direction? direction,
  }) {
    return ArrowCell(
      id: id ?? this.id,
      position: position ?? this.position,
      isActivated: isActivated ?? this.isActivated,
      direction: direction ?? this.direction,
    );
  }

  @override
  List<Object?> get props => [id, position, isActivated, direction];

  @override
  String toString() =>
      'ArrowCell(id: $id, pos: $position, dir: $direction, active: $isActivated)';
}
