import 'failure.dart';

/// An arrow's exit trajectory is blocked by another arrow.
///
/// Carries the IDs of both the moving arrow and the blocker
/// so the BLoC can highlight the collision to the player.
class PathBlockedFailure extends Failure {
  /// ID of the arrow that attempted to exit.
  final String movingArrowId;

  /// ID of the arrow that blocks the trajectory.
  final String blockingArrowId;

  const PathBlockedFailure({
    required this.movingArrowId,
    required this.blockingArrowId,
  }) : super(
          'Arrow "$movingArrowId" path blocked by arrow "$blockingArrowId"',
        );

  @override
  List<Object?> get props => [message, movingArrowId, blockingArrowId];
}
