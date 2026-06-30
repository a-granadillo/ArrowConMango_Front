import 'package:test/test.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/arrow_mapper.dart';

void main() {
  group('ArrowMapper', () {
    test('toModel_converts_entity_to_model', () {
      // Arrange
      final entity = ArrowEntity(
        id: 'arrow1',
        direction: CardinalDirection.right,
        occupiedNodes: [
          Grid2DNodeId(row: 0, col: 0),
          Grid2DNodeId(row: 0, col: 1),
          Grid2DNodeId(row: 0, col: 2),
        ],
      );

      // Act
      final model = ArrowMapper.toModel(entity);

      // Assert
      expect(model.id, equals('arrow1'));
      expect(model.direction, equals('right'));
      expect(model.occupiedNodes.length, equals(3));
      expect(model.occupiedNodes[0].row, equals(0));
      expect(model.occupiedNodes[0].col, equals(0));
    });

    test('toEntity_converts_model_to_entity', () {
      // Arrange
      final model = ArrowModel(
        id: 'arrow2',
        direction: 'up',
        occupiedNodes: [
          const NodeModel(row: 2, col: 3),
          const NodeModel(row: 1, col: 3),
        ],
      );

      // Act
      final entity = ArrowMapper.toEntity(model);

      // Assert
      expect(entity.id, equals('arrow2'));
      expect(entity.direction, equals(CardinalDirection.up));
      expect(entity.occupiedNodes.length, equals(2));
      expect((entity.occupiedNodes[0] as Grid2DNodeId).row, equals(2));
      expect((entity.occupiedNodes[0] as Grid2DNodeId).col, equals(3));
    });

    test('roundtrip_entity_to_model_to_entity', () {
      // Arrange
      final original = ArrowEntity(
        id: 'arrow3',
        direction: CardinalDirection.down,
        occupiedNodes: [
          Grid2DNodeId(row: 1, col: 1),
          Grid2DNodeId(row: 2, col: 1),
          Grid2DNodeId(row: 3, col: 1),
        ],
      );

      // Act
      final model = ArrowMapper.toModel(original);
      final restored = ArrowMapper.toEntity(model);

      // Assert
      expect(restored.id, equals(original.id));
      expect(restored.direction, equals(original.direction));
      expect(restored.occupiedNodes.length, equals(original.occupiedNodes.length));
      for (var i = 0; i < original.occupiedNodes.length; i++) {
        final originalNode = original.occupiedNodes[i] as Grid2DNodeId;
        final restoredNode = restored.occupiedNodes[i] as Grid2DNodeId;
        expect(restoredNode.row, equals(originalNode.row));
        expect(restoredNode.col, equals(originalNode.col));
      }
    });

    test('model_serialization_toMap_fromMap', () {
      // Arrange
      final model = ArrowModel(
        id: 'arrow4',
        direction: 'left',
        occupiedNodes: [
          const NodeModel(row: 5, col: 5),
          const NodeModel(row: 5, col: 4),
        ],
      );

      // Act
      final map = model.toMap();
      final restored = ArrowModel.fromMap(map);

      // Assert
      expect(restored.id, equals(model.id));
      expect(restored.direction, equals(model.direction));
      expect(restored.occupiedNodes.length, equals(model.occupiedNodes.length));
      expect(restored.occupiedNodes[0].row, equals(5));
      expect(restored.occupiedNodes[0].col, equals(5));
    });

    test('toEntity_throws_on_invalid_direction', () {
      // Arrange
      final model = ArrowModel(
        id: 'arrow5',
        direction: 'invalid',
        occupiedNodes: [const NodeModel(row: 0, col: 0)],
      );

      // Act & Assert
      expect(
        () => ArrowMapper.toEntity(model),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
