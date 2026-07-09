import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/arrow_trajectory.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';
import 'package:arrowconmango_front/features/game/data/models/trajectory_segment.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';

ArrowModel arrowHelper(String id, String direction, List<List<int>> cells) {
  final startNode = NodeModel(row: cells.first[0], col: cells.first[1]);
  return ArrowModel(
    id: id,
    startNode: startNode,
    trajectory: ArrowTrajectory(
      segments: [
        TrajectorySegment(
          direction: switch (direction) {
            'up' => CardinalDirection.up,
            'down' => CardinalDirection.down,
            'left' => CardinalDirection.left,
            'right' => CardinalDirection.right,
            _ => throw ArgumentError('Invalid direction: $direction'),
          },
          length: cells.length - 1,
        ),
      ],
    ),
  );
}
