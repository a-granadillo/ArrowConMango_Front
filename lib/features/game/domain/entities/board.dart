import 'package:equatable/equatable.dart';

import 'arrow_cell.dart';
import 'cell.dart';
import 'cell_component.dart';
import 'direction.dart';
import 'path_step.dart';
import 'position.dart';

/// The game board � a composite collection of [CellComponent]s arranged in a grid.
///
/// Implements [CellComponent] (Composite pattern) so that [Board] and [Cell]
/// can be treated uniformly by client code.
///
/// ## Immutability
///
/// All fields are `final`.  Methods that appear to mutate ([replaceCell],
/// [executeAction], [rotateCellAt]) return **new** [Board] instances so that
/// the BLoC layer can correctly detect state changes via [Equatable].
///
/// ## Path Tracing � `isPathClear`
///
/// Traces a path starting from `start` utilizing each cell's `evaluatePath`.
/// The traversal uses a `visited` [Set]<[String]> keyed by position and
/// direction to **prevent infinite loops**.
class Board extends Equatable implements CellComponent {
  /// All composite elements (Cells or nested Boards).
  final List<CellComponent> components;

  /// O(1) positional lookup (automatically flattens nested Boards).
  final Map<Position, Cell> _cellMap;

  /// Number of rows in the grid.
  final int rows;

  /// Number of columns in the grid.
  final int cols;

  /// Named constructor that connects the internal composite map.
  // ignore: prefer_const_constructors_in_immutables
  Board.fromComponents({
    required this.components,
    required this.rows,
    required this.cols,
  })  : _cellMap = _extractCells(components);

  /// Helper to recursively extract all Cells from the Composite.
  static Map<Position, Cell> _extractCells(List<CellComponent> comps) {
    final map = <Position, Cell>{};
    for (final c in comps) {
      if (c is Cell) {
        map[c.position] = c;
      } else if (c is Board) {
        map.addAll(c._cellMap);
      }
    }
    return map;
  }

  /// Creates an empty board with the given dimensions.
  const Board.empty({required this.rows, required this.cols})
      : components = const [],
        _cellMap = const {};

  /// Support for existing code relying on a flattened list of cells.
  List<Cell> get cells => _cellMap.values.toList();

  /// O(1) lookup for the cell at [position], or `null` if out of bounds.
  Cell? getCellAt(Position position) => _cellMap[position];

  /// [CellResolver] callback wired to this board's internal map.
  CellResolver get cellResolver => (Position pos) => _cellMap[pos];

  // ---------------------------------------------------------------------------
  // Path Tracing
  // ---------------------------------------------------------------------------

  /// Determines whether a valid path exists from [start] to the exit.
  bool isPathClear(Position start) {
    final visited = <String>{};
    Position current = start;

    // Determine initial direction if starting on an ArrowCell
    Direction currentDir = Direction.up;
    final startCell = _cellMap[start];
    if (startCell is ArrowCell) {
      currentDir = startCell.direction;
    }

    while (true) {
      // Use both position and direction to prevent empty cell loops properly
      final key = '${current.key}_${currentDir.index}';
      if (!visited.add(key)) {
        return false;
      }

      final cell = _cellMap[current];
      if (cell == null) return false;

      final step = cell.evaluatePath(currentDir);
      
      if (step.outcome == PathOutcome.exitReached) return true;
      if (step.outcome == PathOutcome.blocked) return false;
      
      if (step.outcome == PathOutcome.continuePath) {
        currentDir = step.nextDirection;
        current = current.move(currentDir);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Mutation helpers (all return new Board instances)
  // ---------------------------------------------------------------------------

  /// Returns a new [Board] where the cell matching [newCell.position] is
  /// replaced with [newCell] deep inside the composite structure.
  Board replaceCell(Cell newCell) {
    final newComponents = components.map<CellComponent>((c) {
      if (c is Cell && c.position == newCell.position) return newCell;
      if (c is Board) return c.replaceCell(newCell);
      return c;
    }).toList();
    return Board.fromComponents(components: newComponents, rows: rows, cols: cols);
  }

  /// Convenience method: rotates the [ArrowCell] at [position] and returns
  /// the updated [Board].  Non-arrow cells are left as-is.
  Board rotateCellAt(Position position) {
    final cell = _cellMap[position];
    if (cell == null) return this;
    return replaceCell(cell.rotate());
  }

  /// Adds a [component] to the board, returning a new [Board] instance.
  Board addComponent(CellComponent component) {
    final newComponents = [...components, component];
    return Board.fromComponents(components: newComponents, rows: rows, cols: cols);
  }

  // ---------------------------------------------------------------------------
  // CellComponent implementation
  // ---------------------------------------------------------------------------

  @override
  Board executeAction() => clone();

  // ---------------------------------------------------------------------------
  // Deep copy (clone) & copyWith
  // ---------------------------------------------------------------------------

  /// Creates a **deep**, structurally-independent copy of this composite.
  Board clone() {
    final newComponents = components.map<CellComponent>((c) {
      if (c is Cell) return c.copyWith();
      if (c is Board) return c.clone();
      return c;
    }).toList();
    return Board.fromComponents(components: newComponents, rows: rows, cols: cols);
  }

  /// Returns a new [Board] with the specified fields replaced.
  Board copyWith({
    List<CellComponent>? components,
    int? rows,
    int? cols,
  }) {
    return Board.fromComponents(
      components: components ?? this.components,
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  List<Object?> get props => [components, rows, cols];

  @override
  String toString() =>
      'Board(rows: $rows, cols: $cols, componentCount: ${components.length})';
}
