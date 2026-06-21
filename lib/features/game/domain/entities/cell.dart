import 'package:equatable/equatable.dart';

import 'cell_component.dart';
import 'direction.dart';
import 'path_step.dart';
import 'position.dart';

/// Callback signature that resolves a [Position] to its current [Cell].
///
/// Defined here (rather than inside [Board]) to **break the circular
/// dependency** between [Cell] and [Board]: [Cell] can accept a resolver
/// without ever importing the concrete [Board] class.
///
/// Returns `null` when the position is out of bounds or no cell exists.
typedef CellResolver = Cell? Function(Position position);

/// Abstract node in the directed graph that models the game board.
///
/// Every cell knows its own identity ([id], [position]) and whether it is
/// currently [isActivated].  Subclasses define the semantics of
/// [rotate] and [executeAction].
///
/// **Immutability contract**:  all public fields are `final` and every
/// mutating-looking method returns a **new** instance via [copyWith].
abstract class Cell extends Equatable implements CellComponent {
  /// Unique identifier for this cell within the board (e.g. `'cell_2_3'`).
  final String id;

  /// Grid position of this cell.
  final Position position;

  /// Whether the cell is currently activated (e.g. has been visited or
  /// is part of an active path).
  final bool isActivated;

  const Cell({
    required this.id,
    required this.position,
    this.isActivated = false,
  });

  /// Returns the neighbouring [Cell] in the given [direction] using the
  /// provided [resolver], or `null` if no cell exists at that position.
  ///
  /// This method does **not** store neighbour references internally;
  /// resolution is delegated to the callback to preserve strict
  /// immutability and avoid circular imports.
  Cell? getConnectedCell(Direction direction, CellResolver resolver) {
    final nextPosition = position.move(direction);
    return resolver(nextPosition);
  }

  /// Creates a new [Cell] instance — of the same runtime type — representing
  /// the cell after one clockwise rotation.
  ///
  /// For arrow cells this advances the [Direction]; for walls, empty cells,
  /// and exits this is a no-op that returns an identical copy.
  @override
  Cell executeAction() => rotate();

  /// Returns a new [Cell] with the arrow rotated 90° clockwise.
  ///
  /// Must be overridden by concrete subclasses.
  Cell rotate();

  /// Evaluates how this cell interacts with a path tracing algorithm.
  /// 
  /// [incomingDirection] indicates the direction the path was traveling
  /// when it entered this cell. The cell returns a [PathStep] indicating
  /// whether the path continues, is blocked, or reached the exit.
  PathStep evaluatePath(Direction incomingDirection);

  /// Deep-clone helper.
  ///
  /// Returns a new cell of the same type with the provided fields replaced.
  /// Each subclass must implement its own typed [copyWith].
  Cell copyWith({
    String? id,
    Position? position,
    bool? isActivated,
  });

  @override
  List<Object?> get props => [id, position, isActivated];

  @override
  String toString() =>
      '$runtimeType(id: $id, position: $position, activated: $isActivated)';
}
