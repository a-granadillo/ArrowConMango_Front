import 'package:equatable/equatable.dart';

import '../errors/overlapping_arrows_failure.dart';
import 'arrow_entity.dart';
import 'node_id.dart';

/// Immutable snapshot of all arrows on the board and their spatial occupancy.
///
/// Maintains a reverse index ([_nodeIndex]) for O(1) collision lookups:
/// given any [NodeId], it can instantly tell which arrow (if any) occupies it.
///
/// This is a PURE STATE CONTAINER. It does not compute trajectories
/// or validate movements — that is the responsibility of [CollisionValidator]
/// and [Topology].
class BoardState extends Equatable {
  /// All arrows currently on the board, keyed by arrow ID.
  final Map<String, ArrowEntity> _arrows;

  /// Reverse index: NodeId.key → ArrowEntity.id
  /// Enables O(1) "which arrow is at this node?" queries.
  final Map<String, String> _nodeIndex;

  BoardState({required List<ArrowEntity> arrows})
      : _arrows = Map.unmodifiable({for (final a in arrows) a.id: a}),
        _nodeIndex = Map.unmodifiable(_buildNodeIndex(arrows));

  static Map<String, String> _buildNodeIndex(List<ArrowEntity> arrows) {
    final index = <String, String>{};
    for (final arrow in arrows) {
      for (final node in arrow.occupiedNodes) {
        final existing = index[node.key];
        if (existing != null) {
          throw OverlappingArrowsFailure(
            nodeKey: node.key,
            arrowIds: [existing, arrow.id],
          );
        }
        index[node.key] = arrow.id;
      }
    }
    return index;
  }

  /// O(1) lookup: which arrow occupies [node], or null if empty.
  ArrowEntity? getArrowAtNode(NodeId node) {
    final arrowId = _nodeIndex[node.key];
    return arrowId != null ? _arrows[arrowId] : null;
  }

  /// O(1) lookup: get arrow by its ID.
  ArrowEntity? getArrowById(String id) => _arrows[id];

  /// All arrows currently on the board.
  List<ArrowEntity> get arrows => _arrows.values.toList();

  /// Number of arrows remaining.
  int get arrowCount => _arrows.length;

  /// Whether the board has no arrows (win condition).
  bool get isEmpty => _arrows.isEmpty;

  /// Returns a new [BoardState] with [arrow] removed (it exited the board).
  BoardState withoutArrow(ArrowEntity arrow) {
    final newArrows = _arrows.values.where((a) => a.id != arrow.id).toList();
    return BoardState(arrows: newArrows);
  }

  /// Returns a new [BoardState] with [arrow] replaced by [updated].
  BoardState replacing(ArrowEntity updated) {
    final newArrows = _arrows.values
        .map((a) => a.id == updated.id ? updated : a)
        .toList();
    return BoardState(arrows: newArrows);
  }

  @override
  List<Object?> get props => [_arrows];
}
