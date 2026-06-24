import 'package:test/test.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/node_id.dart';
import 'package:arrowconmango_front/features/game/domain/services/collision_validator.dart';

void main() {
  group('CollisionValidator', () {
    Grid2DNodeId node(int row, int col) => Grid2DNodeId(row: row, col: col);

    ArrowEntity arrow({
      required String id,
      required List<NodeId> nodes,
      Direction direction = CardinalDirection.right,
    }) =>
        ArrowEntity(id: id, direction: direction, occupiedNodes: nodes);

    BoardState state(List<ArrowEntity> arrows) => BoardState(arrows: arrows);

    late final validator = CollisionValidator(Grid2DTopology(rows: 5, cols: 5));

    test('should_allow_exit_when_path_is_clear', () {
      // Arrange
      final mover = arrow(id: 'mover', nodes: [node(2, 0)]);
      final board = state([mover]);

      // Act
      final result = validator.checkExit(mover, board);

      // Assert
      expect(result.canExit, isTrue);
      expect(result.blockingArrowId, isNull);
      expect(
        result.clearPath,
        equals([node(2, 1), node(2, 2), node(2, 3), node(2, 4)]),
      );
    });

    test('should_block_exit_when_another_arrow_in_path', () {
      // Arrange
      final mover = arrow(id: 'mover', nodes: [node(2, 0)]);
      final blocker = arrow(id: 'blocker', nodes: [node(2, 3)]);
      final board = state([mover, blocker]);

      // Act
      final result = validator.checkExit(mover, board);

      // Assert
      expect(result.canExit, isFalse);
      expect(result.blockingArrowId, equals('blocker'));
      expect(result.clearPath, equals([node(2, 1), node(2, 2)]));
    });

    test('should_allow_exit_when_arrow_points_at_boundary', () {
      // Arrange
      final mover = arrow(
        id: 'mover',
        nodes: [node(0, 0)],
        direction: CardinalDirection.up,
      );
      final board = state([mover]);

      // Act
      final result = validator.checkExit(mover, board);

      // Assert
      expect(result.canExit, isTrue);
      expect(result.blockingArrowId, isNull);
      expect(result.clearPath, isEmpty);
    });

    test('should_return_partial_clear_path_when_blocked', () {
      // Arrange
      final mover = arrow(
        id: 'mover',
        nodes: [node(1, 1)],
        direction: CardinalDirection.down,
      );
      final blocker = arrow(id: 'blocker', nodes: [node(3, 1)]);
      final board = state([mover, blocker]);

      // Act
      final result = validator.checkExit(mover, board);

      // Assert
      expect(result.canExit, isFalse);
      expect(result.blockingArrowId, equals('blocker'));
      expect(result.clearPath, equals([node(2, 1)]));
    });

    test('should_allow_slide_when_target_nodes_empty', () {
      // Arrange
      final mover = arrow(
        id: 'mover',
        nodes: [node(2, 1), node(2, 2)],
        direction: CardinalDirection.right,
      );
      final board = state([mover]);

      // Act
      final canSlide = validator.canSlide(mover, board, 1);

      // Assert
      expect(canSlide, isTrue);
    });

    test('should_block_slide_when_target_occupied', () {
      // Arrange
      final mover = arrow(
        id: 'mover',
        nodes: [node(2, 1), node(2, 2)],
        direction: CardinalDirection.right,
      );
      final obstacle = arrow(id: 'obstacle', nodes: [node(2, 3)]);
      final board = state([mover, obstacle]);

      // Act
      final canSlide = validator.canSlide(mover, board, 1);

      // Assert
      expect(canSlide, isFalse);
    });
  });
}
