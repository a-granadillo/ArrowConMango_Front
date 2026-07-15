import '../entities/arrow_entity.dart';
import '../entities/board_state.dart';
import '../entities/exit_check_result.dart';
import '../entities/node_id.dart';
import 'topology.dart';

/// Domain service that validates whether an arrow's exit trajectory is clear.
///
/// Depends ONLY on [TrajectoryProvider] (ISP) — it does not need adjacency
/// or boundary queries. Receives the topology via constructor injection (DIP).
///
/// This class contains NO spatial math. It orchestrates queries between
/// [Topology] and [BoardState] to produce a verdict.
class CollisionValidator {
  final TrajectoryProvider _topology;

  const CollisionValidator(this._topology);

  /// Determines whether [arrow] can exit the board from its current position.
  ///
  /// Returns an [ExitCheckResult] containing:
  ///   - [canExit]: true if the entire trajectory from the arrow's head
  ///     to the board boundary is free of other arrows.
  ///   - [blockingArrowId]: the ID of the first arrow that blocks the path,
  ///     or null if the path is clear.
  ///   - [clearPath]: the list of unoccupied nodes in the trajectory
  ///     (empty if blocked at the first node, full if path is clear).
  ExitCheckResult checkExit(ArrowEntity arrow, BoardState board) {
    final trajectory = _topology.getTrajectory(
      arrow.headNode,
      arrow.direction,
    );

    final clearPath = <NodeId>[];

    for (final node in trajectory) {
      final occupant = board.getArrowAtNode(node);

      if (occupant != null && occupant.id != arrow.id) {
        return ExitCheckResult(
          canExit: false,
          blockingArrowId: occupant.id,
          clearPath: clearPath,
        );
      }

      clearPath.add(node);
    }

    return ExitCheckResult(
      canExit: true,
      blockingArrowId: null,
      clearPath: clearPath,
    );
  }

  /// Checks if [arrow] can slide exactly [steps] forward without collision.
  /// Used for partial-slide mechanics (if applicable to specific levels).
  bool canSlide(ArrowEntity arrow, BoardState board, int steps) {
    final newNodes = _topology.getShiftedNodes(
      headPosition: arrow.headNode,
      direction: arrow.direction,
      length: arrow.length,
      steps: steps,
    );

    for (final node in newNodes) {
      final occupant = board.getArrowAtNode(node);
      if (occupant != null && occupant.id != arrow.id) {
        return false;
      }
    }

    return true;
  }
}
