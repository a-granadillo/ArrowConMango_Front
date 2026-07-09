import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/arrow_trajectory.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';
import 'package:arrowconmango_front/features/game/data/models/trajectory_segment.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';

/// Converts [ArrowModel] to/from [ArrowEntity].
///
/// This mapper assumes a 2D rectangular board: node models are mapped to
/// [Grid2DNodeId] and direction labels are mapped to [CardinalDirection].
class ArrowMapper {
  const ArrowMapper();

  ArrowEntity toEntity(ArrowModel model) {
    final startNode = Grid2DNodeId(row: model.startNode.row, col: model.startNode.col);
    final nodes = model.trajectory.toNodes(startNode);

    return ArrowEntity(
      id: model.id,
      direction: model.trajectory.finalDirection,
      occupiedNodes: nodes,
    );
  }

  ArrowModel toModel(ArrowEntity entity) {
    if (entity.occupiedNodes.isEmpty) {
      throw ArgumentError('ArrowEntity must have at least one occupied node');
    }

    if (entity.direction is! CardinalDirection) {
      throw ArgumentError(
        'ArrowMapper only supports CardinalDirection, got ${entity.direction.runtimeType}. '
        'Use a topology-specific mapper for other directions.',
      );
    }

    final gridNodes = entity.occupiedNodes.map((node) {
      if (node is! Grid2DNodeId) {
        throw ArgumentError(
          'ArrowMapper only supports Grid2DNodeId, got ${node.runtimeType}. '
          'Use a topology-specific mapper for other node types.',
        );
      }
      return node;
    }).toList();

    if (gridNodes.length < 2) {
      final direction = entity.direction as CardinalDirection;
      return ArrowModel(
        id: entity.id,
        startNode: NodeModel(row: gridNodes.first.row, col: gridNodes.first.col),
        trajectory: ArrowTrajectory(
          segments: [TrajectorySegment(direction: direction, length: 0)],
        ),
      );
    }

    final segments = <TrajectorySegment>[];
    final directions = <CardinalDirection>[];
    for (var i = 0; i < gridNodes.length - 1; i++) {
      directions.add(_inferDirection(gridNodes[i], gridNodes[i + 1]));
    }

    var currentDirection = directions[0];
    var currentLength = 1;

    for (var i = 1; i < directions.length; i++) {
      if (directions[i] == currentDirection) {
        currentLength++;
      } else {
        segments.add(TrajectorySegment(direction: currentDirection, length: currentLength));
        currentDirection = directions[i];
        currentLength = 1;
      }
    }
    segments.add(TrajectorySegment(direction: currentDirection, length: currentLength));

    final startNode = NodeModel(row: gridNodes.first.row, col: gridNodes.first.col);
    final trajectory = ArrowTrajectory(segments: segments);

    return ArrowModel(
      id: entity.id,
      startNode: startNode,
      trajectory: trajectory,
    );
  }

  /// Infers the direction from one node to the next.
  CardinalDirection _inferDirection(Grid2DNodeId from, Grid2DNodeId to) {
    final rowDiff = to.row - from.row;
    final colDiff = to.col - from.col;

    if (rowDiff == -1 && colDiff == 0) return CardinalDirection.up;
    if (rowDiff == 1 && colDiff == 0) return CardinalDirection.down;
    if (rowDiff == 0 && colDiff == -1) return CardinalDirection.left;
    if (rowDiff == 0 && colDiff == 1) return CardinalDirection.right;

    throw ArgumentError(
      'Cannot infer direction from ($from.row, $from.col) to ($to.row, $to.col). '
      'Nodes must be adjacent in a cardinal direction.',
    );
  }
}
