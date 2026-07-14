import 'package:equatable/equatable.dart';

import 'direction.dart';
import 'node_id.dart';

/// An arrow in the puzzle — a multi-node object with a head and tail.
///
/// Occupies [length] contiguous nodes along its [direction] axis.
/// The [occupiedNodes] list is ordered: index 0 = tail, last index = head.
///
/// This entity is TOPOLOGY-AGNOSTIC. It stores node references but
/// never computes paths, distances, or spatial relationships.
class ArrowEntity extends Equatable {
  /// Unique identifier for this arrow within the board.
  final String id;

  /// The direction this arrow points (toward its head).
  final Direction direction;

  /// Ordered list of nodes occupied by this arrow.
  /// [0] = tail, [length-1] = head.
  final List<NodeId> occupiedNodes;

  /// Number of nodes this arrow spans.
  int get length => occupiedNodes.length;

  /// The leading node (the tip of the arrow).
  NodeId get headNode => occupiedNodes.last;

  /// The trailing node (the base of the arrow).
  NodeId get tailNode => occupiedNodes.first;

  final bool isSwitchable;

  const ArrowEntity({
    required this.id,
    required this.direction,
    required this.occupiedNodes,
    this.isSwitchable = false,
  });

  /// Returns a new [ArrowEntity] with its occupied nodes replaced.
  /// Used after the arrow slides forward by N steps.
  ArrowEntity withShiftedNodes(List<NodeId> newNodes) {
    return ArrowEntity(
      id: id,
      direction: direction,
      occupiedNodes: newNodes,
      isSwitchable: isSwitchable,
    );
  }

  /// Returns a new [ArrowEntity] pointing in [newDirection].
  ArrowEntity withDirection(Direction newDirection) {
    return ArrowEntity(
      id: id,
      direction: newDirection,
      occupiedNodes: occupiedNodes,
      isSwitchable: isSwitchable,
    );
  }

  @override
  List<Object?> get props => [id, direction, occupiedNodes, isSwitchable];
}
