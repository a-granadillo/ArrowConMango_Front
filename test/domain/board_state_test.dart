import 'package:test/test.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/node_id.dart';

void main() {
  group('BoardState', () {
    Grid2DNodeId node(int row, int col) => Grid2DNodeId(row: row, col: col);

    ArrowEntity arrow({
      required String id,
      required List<NodeId> nodes,
      Direction direction = CardinalDirection.right,
    }) =>
        ArrowEntity(id: id, direction: direction, occupiedNodes: nodes);

    BoardState state(List<ArrowEntity> arrows) => BoardState(arrows: arrows);

    test('should_find_arrow_at_node_when_arrow_exists', () {
      // Arrange
      final arrow1 = arrow(id: 'a', nodes: [node(0, 0), node(0, 1)]);
      final arrow2 = arrow(id: 'b', nodes: [node(1, 1), node(1, 2)]);
      final board = state([arrow1, arrow2]);

      // Act
      final found = board.getArrowAtNode(node(0, 0));

      // Assert
      expect(found, equals(arrow1));
    });

    test('should_return_null_when_no_arrow_at_node', () {
      // Arrange
      final arrow1 = arrow(id: 'a', nodes: [node(0, 0), node(0, 1)]);
      final board = state([arrow1]);

      // Act
      final found = board.getArrowAtNode(node(3, 3));

      // Assert
      expect(found, isNull);
    });

    test('should_find_arrow_by_id_when_arrow_exists', () {
      // Arrange
      final arrow1 = arrow(id: 'a', nodes: [node(0, 0), node(0, 1)]);
      final board = state([arrow1]);

      // Act
      final found = board.getArrowById('a');

      // Assert
      expect(found, equals(arrow1));
    });

    test('should_return_null_when_id_not_found', () {
      // Arrange
      final arrow1 = arrow(id: 'a', nodes: [node(0, 0), node(0, 1)]);
      final board = state([arrow1]);

      // Act
      final found = board.getArrowById('z');

      // Assert
      expect(found, isNull);
    });

    test('should_remove_arrow_when_withoutArrow_called', () {
      // Arrange
      final arrow1 = arrow(id: 'a', nodes: [node(0, 0), node(0, 1)]);
      final arrow2 = arrow(id: 'b', nodes: [node(1, 1), node(1, 2)]);
      final original = state([arrow1, arrow2]);

      // Act
      final updated = original.withoutArrow(arrow1);

      // Assert
      expect(original.arrowCount, equals(2));
      expect(original.getArrowById('a'), isNotNull);
      expect(updated.arrowCount, equals(1));
      expect(updated.getArrowById('a'), isNull);
      expect(updated.getArrowById('b'), equals(arrow2));
    });

    test('should_replace_arrow_when_replacing_called', () {
      // Arrange
      final originalArrow = arrow(id: 'a', nodes: [node(0, 0), node(0, 1)]);
      final updatedArrow = arrow(id: 'a', nodes: [node(0, 1), node(0, 2)]);
      final original = state([originalArrow]);

      // Act
      final updated = original.replacing(updatedArrow);

      // Assert
      expect(original.getArrowById('a'), equals(originalArrow));
      expect(updated.getArrowById('a'), equals(updatedArrow));
    });

    test('should_report_empty_when_no_arrows', () {
      // Arrange
      final board = state([]);

      // Act
      final isEmpty = board.isEmpty;

      // Assert
      expect(isEmpty, isTrue);
    });

    test('should_report_correct_arrow_count', () {
      // Arrange
      final arrow1 = arrow(id: 'a', nodes: [node(0, 0)]);
      final arrow2 = arrow(id: 'b', nodes: [node(1, 1)]);
      final board = state([arrow1, arrow2]);

      // Act
      final count = board.arrowCount;

      // Assert
      expect(count, equals(2));
    });

    test('should_rebuild_node_index_when_state_changes', () {
      // Arrange
      final arrow1 = arrow(id: 'a', nodes: [node(0, 0), node(0, 1)]);
      final original = state([arrow1]);

      // Act
      final updated = original.withoutArrow(arrow1);

      // Assert
      expect(original.getArrowAtNode(node(0, 0)), equals(arrow1));
      expect(updated.getArrowAtNode(node(0, 0)), isNull);
      expect(updated.getArrowAtNode(node(0, 1)), isNull);
    });
  });
}
