import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/arrow_trajectory.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';
import 'package:arrowconmango_front/features/game/data/models/trajectory_segment.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';

ArrowModel arrowHelper(String id, String direction, List<List<int>> cells) {
  final startNode = NodeModel(row: cells.first[0], col: cells.first[1]);

  final finalDirection = switch (direction) {
    'up' => CardinalDirection.up,
    'down' => CardinalDirection.down,
    'left' => CardinalDirection.left,
    'right' => CardinalDirection.right,
    _ => throw ArgumentError('Invalid direction: $direction'),
  };

  // Single-node arrow
  if (cells.length == 1) {
    return ArrowModel(
      id: id,
      startNode: startNode,
      trajectory: ArrowTrajectory(
        segments: [TrajectorySegment(direction: finalDirection, length: 0)],
      ),
    );
  }

  // Derive segments from consecutive cell deltas
  final segments = <TrajectorySegment>[];
  CardinalDirection? currentSegmentDir;
  int currentLength = 0;

  for (int i = 0; i < cells.length - 1; i++) {
    final curr = cells[i];
    final next = cells[i + 1];

    final dRow = next[0] - curr[0];
    final dCol = next[1] - curr[1];

    CardinalDirection stepDir;
    if (dRow == -1 && dCol == 0) stepDir = CardinalDirection.up;
    else if (dRow == 1 && dCol == 0) stepDir = CardinalDirection.down;
    else if (dRow == 0 && dCol == -1) stepDir = CardinalDirection.left;
    else if (dRow == 0 && dCol == 1) stepDir = CardinalDirection.right;
    else throw ArgumentError('Cells must be adjacent orthogonally. Got jump from [${curr[0]},${curr[1]}] to [${next[0]},${next[1]}]');

    if (currentSegmentDir == stepDir) {
      currentLength++;
    } else {
      if (currentSegmentDir != null) {
        segments.add(TrajectorySegment(direction: currentSegmentDir, length: currentLength));
      }
      currentSegmentDir = stepDir;
      currentLength = 1;
    }
  }

  // Add the final segment
  if (currentSegmentDir != null) {
    segments.add(TrajectorySegment(direction: currentSegmentDir, length: currentLength));
  }

  // Validate that the final segment direction matches the provided 'direction'
  if (segments.isNotEmpty && segments.last.direction != finalDirection) {
    throw ArgumentError('The final derived direction (${segments.last.direction}) does not match the requested arrow direction ($finalDirection)');
  }

  return ArrowModel(
    id: id,
    startNode: startNode,
    trajectory: ArrowTrajectory(segments: segments),
  );
}
