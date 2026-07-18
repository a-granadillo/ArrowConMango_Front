import 'package:test/test.dart';
import 'package:arrowconmango_front/features/game/data/topologies/hex_graph.dart';
import 'package:arrowconmango_front/features/game/data/topologies/hex_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/hex_direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/node_id.dart';

class _FakeNodeId extends NodeId {
  const _FakeNodeId();

  @override
  String get key => 'fake';

  @override
  List<Object?> get props => [key];
}

void main() {
  group('HexTopology', () {
    // Hexagon of radius 2 (19 cells), axial coordinates (q, r).
    late final topology = HexTopology(radius: 2);

    HexNodeId node(int q, int r) => HexNodeId(q: q, r: r);

    test('should_have_19_cells_for_radius_2', () {
      expect(topology.nodeCount, equals(19));
    });

    test('should_return_correct_trajectory_when_moving_north_from_center', () {
      // Arrange
      final start = node(0, 0);

      // Act
      final trajectory = topology.getTrajectory(start, HexDirection.n);

      // Assert
      expect(trajectory, equals([node(0, -1), node(0, -2)]));
    });

    test('should_return_empty_trajectory_when_at_boundary', () {
      // Arrange
      final start = node(0, -2);

      // Act
      final trajectory = topology.getTrajectory(start, HexDirection.n);

      // Assert
      expect(trajectory, isEmpty);
    });

    test('should_return_all_nodes_to_boundary_when_moving_southeast', () {
      // Arrange
      final start = node(-2, 0);

      // Act
      final trajectory = topology.getTrajectory(start, HexDirection.se);

      // Assert
      expect(trajectory, equals([node(-1, 0), node(0, 0), node(1, 0), node(2, 0)]));
    });

    test('should_return_shifted_nodes_when_sliding_forward', () {
      // Arrange
      final head = node(0, 0);

      // Act
      final shifted = topology.getShiftedNodes(
        headPosition: head,
        direction: HexDirection.n,
        length: 2,
        steps: 1,
      );

      // Assert
      expect(shifted, equals([node(0, 0), node(0, -1)]));
    });

    test('should_return_correct_neighbor_when_within_bounds', () {
      // Arrange
      final origin = node(0, 0);

      // Act
      final neighbor = topology.getNeighbor(origin, HexDirection.se);

      // Assert
      expect(neighbor, equals(node(1, 0)));
    });

    test('should_return_null_neighbor_when_at_boundary', () {
      // Arrange
      final origin = node(0, -2);

      // Act
      final neighbor = topology.getNeighbor(origin, HexDirection.n);

      // Assert
      expect(neighbor, isNull);
    });

    test('should_report_contains_true_when_node_inside', () {
      expect(topology.contains(node(0, 0)), isTrue);
      expect(topology.contains(node(2, 0)), isTrue);
    });

    test('should_report_contains_false_when_node_outside_radius', () {
      expect(topology.contains(node(5, 5)), isFalse);
    });

    test('should_report_exit_boundary_when_at_edge', () {
      // Arrange
      final edge = node(0, -2);

      // Act
      final exits = topology.isExitBoundary(edge, HexDirection.n);

      // Assert
      expect(exits, isTrue);
    });

    test('should_report_not_exit_boundary_when_inside', () {
      // Arrange
      final inside = node(0, 0);

      // Act
      final exits = topology.isExitBoundary(inside, HexDirection.n);

      // Assert
      expect(exits, isFalse);
    });

    test('should_expose_all_6_hex_directions_as_supported', () {
      expect(topology.supportedDirections, equals(HexDirection.values));
    });

    test('should_expose_every_generated_cell_via_allNodes', () {
      expect(topology.allNodes, hasLength(19));
      expect(topology.allNodes, contains(node(0, 0)));
    });

    test('should_throw_when_invalid_node_type', () {
      // Arrange
      const fakeNode = _FakeNodeId();

      // Act / Assert
      expect(
        () => topology.getTrajectory(fakeNode, HexDirection.n),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
