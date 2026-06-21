import 'package:equatable/equatable.dart';

import 'node_id.dart';

/// Immutable result of a collision check for an arrow's exit trajectory.
class ExitCheckResult extends Equatable {
  /// Whether the arrow can exit the board (entire path is clear).
  final bool canExit;

  /// ID of the first blocking arrow, or null if path is clear.
  final String? blockingArrowId;

  /// Ordered list of unoccupied nodes from the arrow's head toward the boundary.
  /// If [canExit] is true, this is the complete trajectory.
  /// If [canExit] is false, this is the clear portion before the blocker.
  final List<NodeId> clearPath;

  const ExitCheckResult({
    required this.canExit,
    required this.blockingArrowId,
    required this.clearPath,
  });

  @override
  List<Object?> get props => [canExit, blockingArrowId, clearPath];
}
