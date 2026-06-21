import 'direction.dart';

/// Indicates the result of a path traversing through a cell.
enum PathOutcome {
  /// The path is allowed to continue moving.
  continuePath,

  /// The path is blocked by this cell (e.g. hitting a wall).
  blocked,

  /// The goal has been successfully reached.
  exitReached,
}

/// Encapsulates the evaluation outcome when tracing a path through a cell.
class PathStep {
  /// What happens to the path (continue, block, win).
  final PathOutcome outcome;

  /// The new direction the path should take if it continues.
  final Direction nextDirection;

  const PathStep({
    required this.outcome,
    required this.nextDirection,
  });
}
