import '../entities/arrow_entity.dart';
import '../entities/board_geometry.dart';
import '../entities/board_state.dart';
import '../entities/direction.dart';
import '../entities/level.dart';
import '../entities/node_id.dart';

/// Builder for constructing [Level] instances from structured definitions.
///
/// This builder allows the domain layer to construct levels from
/// configuration data (JSON, YAML, etc.) without coupling to specific
/// serialization libraries or infrastructure concerns.
///
/// Usage:
/// ```dart
/// final level = LevelBuilder()
///   ..levelId = 1
///   ..addArrow(
///     id: 'a1',
///     nodes: [Grid2DNodeId(row: 0, col: 0)],
///     direction: CardinalDirection.right,
///   )
///   ..addArrow(
///     id: 'a2',
///     nodes: [Grid2DNodeId(row: 2, col: 1), Grid2DNodeId(row: 2, col: 2)],
///     direction: CardinalDirection.down,
///   )
///   ..build();
/// ```
class LevelBuilder {
  int? _levelId;
  final List<ArrowEntity> _arrows = [];
  int _rows = 8;
  int _cols = 8;

  /// Sets the level identifier.
  set levelId(int id) => _levelId = id;

  /// Sets the number of rows on the board.
  set rows(int v) => _rows = v;

  /// Sets the number of columns on the board.
  set cols(int v) => _cols = v;

  /// Adds an arrow to the level definition.
  ///
  /// [id] must be unique within this level.
  /// [nodes] is the ordered list of nodes occupied by the arrow (tail → head).
  /// [direction] is the direction the arrow points.
  void addArrow({
    required String id,
    required List<NodeId> nodes,
    required Direction direction,
  }) {
    _arrows.add(ArrowEntity(
      id: id,
      direction: direction,
      occupiedNodes: nodes,
    ));
  }

  /// Constructs the [Level] from the accumulated definitions.
  ///
  /// Throws [StateError] if [levelId] was not set.
  /// Throws [OverlappingArrowsFailure] if arrows occupy the same node.
  Level build() {
    if (_levelId == null) {
      throw StateError('levelId must be set before calling build()');
    }

    final board = BoardState(arrows: _arrows);
    return Level(
      levelId: _levelId!,
      geometry: BoardGeometry2D(rows: _rows, cols: _cols),
      templateBoard: board,
    );
  }

  /// Resets the builder to its initial state for reuse.
  void reset() {
    _levelId = null;
    _arrows.clear();
  }
}
