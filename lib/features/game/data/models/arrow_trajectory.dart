import 'package:equatable/equatable.dart';

import '../../domain/entities/cardinal_direction.dart';
import '../../domain/entities/node_id.dart';
import '../topologies/grid_2d_topology.dart';
import 'trajectory_segment.dart';

/// Represents an arrow's complete trajectory as a sequence of straight segments.
///
/// Each segment has a direction and length. Segments are connected end-to-end,
/// allowing for complex paths with 90° turns.
///
/// Example: A trajectory that goes right 2 cells, then down 3 cells:
/// ```dart
/// ArrowTrajectory(segments: [
///   TrajectorySegment(direction: CardinalDirection.right, length: 2),
///   TrajectorySegment(direction: CardinalDirection.down, length: 3),
/// ])
/// ```
class ArrowTrajectory extends Equatable {
  /// Ordered list of segments that form this trajectory.
  final List<TrajectorySegment> segments;

  ArrowTrajectory({required this.segments})
      : assert(segments.length > 0, 'Trajectory must have at least one segment');

  factory ArrowTrajectory.fromJson(Map<String, dynamic> json) {
    return ArrowTrajectory(
      segments: (json['segments'] as List<dynamic>)
          .map((s) => TrajectorySegment.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'segments': segments.map((s) => s.toJson()).toList(),
    };
  }

  /// Total number of cells this trajectory spans.
  int get totalLength => segments.fold(0, (sum, s) => sum + s.length);

  /// The direction of the final segment (the arrow's head direction).
  CardinalDirection get finalDirection => segments.last.direction;

  /// Converts this trajectory to a list of [NodeId] starting from [startNode].
  ///
  /// The returned list is ordered: index 0 = tail, last index = head.
  /// This method assumes a 2D grid topology.
  List<NodeId> toNodes(Grid2DNodeId startNode) {
    final nodes = <NodeId>[startNode];
    var currentRow = startNode.row;
    var currentCol = startNode.col;

    for (final segment in segments) {
      for (var i = 0; i < segment.length; i++) {
        switch (segment.direction) {
          case CardinalDirection.up:
            currentRow -= 1;
            break;
          case CardinalDirection.down:
            currentRow += 1;
            break;
          case CardinalDirection.left:
            currentCol -= 1;
            break;
          case CardinalDirection.right:
            currentCol += 1;
            break;
        }
        nodes.add(Grid2DNodeId(row: currentRow, col: currentCol));
      }
    }

    return nodes;
  }

  @override
  List<Object?> get props => [segments];
}
