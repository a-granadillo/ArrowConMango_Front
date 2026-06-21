import 'package:test/test.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/node_id.dart';

class _FakeNodeId extends NodeId {
  const _FakeNodeId();

  @override
  String get key => 'fake';

  @override
  List<Object?> get props => [key];
}

void main() {
  group('Grid2DTopology', () {
    const topology = Grid2DTopology(rows: 5, cols: 5);

    Grid2DNodeId node(int row, int col) => Grid2DNodeId(row: row, col: col);

    test('should_return_correct_trajectory_when_moving_up_from_center', () {
      // Arrange
      final start = node(2, 2);

      // Act
      final trajectory = topology.getTrajectory(start, CardinalDirection.up);

      // Assert
      expect(trajectory, equals([node(1, 2), node(0, 2)]));
    });

    test('should_return_empty_trajectory_when_at_boundary', () {
      // Arrange
      final start = node(0, 2);

      // Act
      final trajectory = topology.getTrajectory(start, CardinalDirection.up);

      // Assert
      expect(trajectory, isEmpty);
    });

    test('should_return_correct_trajectory_when_moving_right_from_edge', () {
      // Arrange
      final start = node(2, 4);

      // Act
      final trajectory = topology.getTrajectory(start, CardinalDirection.right);

      // Assert
      expect(trajectory, isEmpty);
    });

    test('should_return_all_nodes_to_boundary_when_moving_down', () {
      // Arrange
      final start = node(0, 0);

      // Act
      final trajectory = topology.getTrajectory(start, CardinalDirection.down);

      // Assert
      expect(
        trajectory,
        equals([node(1, 0), node(2, 0), node(3, 0), node(4, 0)]),
      );
    });

    test('should_return_shifted_nodes_when_sliding_forward', () {
      // Arrange
      final head = node(2, 2);

      // Act
      final shifted = topology.getShiftedNodes(
        headPosition: head,
        direction: CardinalDirection.right,
        length: 2,
        steps: 1,
      );

      // Assert
      expect(shifted, equals([node(2, 2), node(2, 3)]));
    });

    test('should_return_correct_neighbor_when_within_bounds', () {
      // Arrange
      final origin = node(2, 2);

      // Act
      final neighbor = topology.getNeighbor(origin, CardinalDirection.right);

      // Assert
      expect(neighbor, equals(node(2, 3)));
    });

    test('should_return_null_neighbor_when_at_boundary', () {
      // Arrange
      final origin = node(0, 0);

      // Act
      final neighbor = topology.getNeighbor(origin, CardinalDirection.up);

      // Assert
      expect(neighbor, isNull);
    });

    test('should_report_contains_true_when_node_inside', () {
      // Arrange
      final inside = node(2, 2);

      // Act
      final contained = topology.contains(inside);

      // Assert
      expect(contained, isTrue);
    });

    test('should_report_contains_false_when_node_outside', () {
      // Arrange
      final outside = node(-1, 0);

      // Act
      final contained = topology.contains(outside);

      // Assert
      expect(contained, isFalse);
    });

    test('should_report_exit_boundary_when_at_edge', () {
      // Arrange
      final edge = node(0, 2);

      // Act
      final exits = topology.isExitBoundary(edge, CardinalDirection.up);

      // Assert
      expect(exits, isTrue);
    });

    test('should_report_not_exit_boundary_when_inside', () {
      // Arrange
      final inside = node(2, 2);

      // Act
      final exits = topology.isExitBoundary(inside, CardinalDirection.up);

      // Assert
      expect(exits, isFalse);
    });

    test('should_throw_when_invalid_node_type', () {
      // Arrange
      const fakeNode = _FakeNodeId();

      // Act / Assert
      expect(
        () => topology.getTrajectory(fakeNode, CardinalDirection.up),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
