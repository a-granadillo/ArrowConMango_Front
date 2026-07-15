import 'package:test/test.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_3d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/node_id.dart';
import 'package:arrowconmango_front/features/game/domain/entities/spatial_direction.dart';

class _FakeNodeId extends NodeId {
  const _FakeNodeId();

  @override
  String get key => 'fake';

  @override
  List<Object?> get props => [key];
}

void main() {
  group('Grid3DTopology', () {
    // Coordinate convention: x = column, y = row, z = depth (layer).
    late final topology = Grid3DTopology(width: 5, height: 5, depth: 3);

    Cube3DNodeId node(int x, int y, int z) => Cube3DNodeId(x: x, y: y, z: z);

    test('should_return_correct_trajectory_when_moving_up_from_center', () {
      // Arrange
      final start = node(2, 2, 1);

      // Act
      final trajectory = topology.getTrajectory(start, SpatialDirection.up);

      // Assert
      expect(trajectory, equals([node(2, 1, 1), node(2, 0, 1)]));
    });

    test('should_return_empty_trajectory_when_at_boundary', () {
      // Arrange
      final start = node(2, 0, 1);

      // Act
      final trajectory = topology.getTrajectory(start, SpatialDirection.up);

      // Assert
      expect(trajectory, isEmpty);
    });

    test('should_return_correct_trajectory_when_moving_right_from_edge', () {
      // Arrange
      final start = node(4, 2, 1);

      // Act
      final trajectory = topology.getTrajectory(start, SpatialDirection.right);

      // Assert
      expect(trajectory, isEmpty);
    });

    test('should_return_all_nodes_to_boundary_when_moving_down', () {
      // Arrange
      final start = node(0, 0, 1);

      // Act
      final trajectory = topology.getTrajectory(start, SpatialDirection.down);

      // Assert
      expect(
        trajectory,
        equals([node(0, 1, 1), node(0, 2, 1), node(0, 3, 1), node(0, 4, 1)]),
      );
    });

    test('should_return_all_nodes_to_boundary_when_moving_back_along_z', () {
      // Arrange
      final start = node(0, 0, 0);

      // Act
      final trajectory = topology.getTrajectory(start, SpatialDirection.back);

      // Assert
      expect(trajectory, equals([node(0, 0, 1), node(0, 0, 2)]));
    });

    test('should_return_empty_trajectory_when_fwd_at_z_boundary', () {
      // Arrange
      final start = node(0, 0, 0);

      // Act
      final trajectory = topology.getTrajectory(start, SpatialDirection.fwd);

      // Assert
      expect(trajectory, isEmpty);
    });

    test('should_return_shifted_nodes_when_sliding_forward', () {
      // Arrange
      final head = node(2, 2, 1);

      // Act
      final shifted = topology.getShiftedNodes(
        headPosition: head,
        direction: SpatialDirection.right,
        length: 2,
        steps: 1,
      );

      // Assert
      expect(shifted, equals([node(2, 2, 1), node(3, 2, 1)]));
    });

    test('should_return_correct_neighbor_when_within_bounds', () {
      // Arrange
      final origin = node(2, 2, 1);

      // Act
      final neighbor = topology.getNeighbor(origin, SpatialDirection.right);

      // Assert
      expect(neighbor, equals(node(3, 2, 1)));
    });

    test('should_return_null_neighbor_when_at_boundary', () {
      // Arrange
      final origin = node(0, 0, 0);

      // Act
      final neighbor = topology.getNeighbor(origin, SpatialDirection.up);

      // Assert
      expect(neighbor, isNull);
    });

    test('should_return_null_neighbor_when_fwd_at_z_boundary', () {
      // Arrange
      final origin = node(0, 0, 0);

      // Act
      final neighbor = topology.getNeighbor(origin, SpatialDirection.fwd);

      // Assert
      expect(neighbor, isNull);
    });

    test('should_report_contains_true_when_node_inside', () {
      // Arrange
      final inside = node(2, 2, 1);

      // Act
      final contained = topology.contains(inside);

      // Assert
      expect(contained, isTrue);
    });

    test('should_report_contains_false_when_node_outside', () {
      // Arrange
      final outside = node(-1, 0, 0);

      // Act
      final contained = topology.contains(outside);

      // Assert
      expect(contained, isFalse);
    });

    test('should_report_exit_boundary_when_at_edge', () {
      // Arrange
      final edge = node(0, 0, 1);

      // Act
      final exits = topology.isExitBoundary(edge, SpatialDirection.up);

      // Assert
      expect(exits, isTrue);
    });

    test('should_report_not_exit_boundary_when_inside', () {
      // Arrange
      final inside = node(2, 2, 1);

      // Act
      final exits = topology.isExitBoundary(inside, SpatialDirection.up);

      // Assert
      expect(exits, isFalse);
    });

    test('should_expose_all_6_spatial_directions_as_supported', () {
      expect(topology.supportedDirections, equals(SpatialDirection.values));
    });

    test('should_throw_when_invalid_node_type', () {
      // Arrange
      const fakeNode = _FakeNodeId();

      // Act / Assert
      expect(
        () => topology.getTrajectory(fakeNode, SpatialDirection.up),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
