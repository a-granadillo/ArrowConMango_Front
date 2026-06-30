import 'package:test/test.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/data/models/board_state_model.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/board_state_mapper.dart';

void main() {
  group('BoardStateMapper', () {
    test('toModel_converts_entity_to_model', () {
      // Arrange
      final entity = BoardState(
        arrows: [
          ArrowEntity(
            id: 'arrow1',
            direction: CardinalDirection.right,
            occupiedNodes: [
              Grid2DNodeId(row: 0, col: 0),
              Grid2DNodeId(row: 0, col: 1),
            ],
          ),
          ArrowEntity(
            id: 'arrow2',
            direction: CardinalDirection.down,
            occupiedNodes: [
              Grid2DNodeId(row: 2, col: 2),
            ],
          ),
        ],
      );

      // Act
      final model = BoardStateMapper.toModel(entity);

      // Assert
      expect(model.arrows.length, equals(2));
      expect(model.arrows[0].id, equals('arrow1'));
      expect(model.arrows[1].id, equals('arrow2'));
    });

    test('toEntity_converts_model_to_entity', () {
      // Arrange
      final model = BoardStateModel(
        arrows: [
          ArrowModel(
            id: 'arrow1',
            direction: 'up',
            occupiedNodes: [
              const NodeModel(row: 1, col: 1),
            ],
          ),
        ],
      );

      // Act
      final entity = BoardStateMapper.toEntity(model);

      // Assert
      expect(entity.arrowCount, equals(1));
      expect(entity.getArrowById('arrow1'), isNotNull);
    });

    test('roundtrip_entity_to_model_to_entity', () {
      // Arrange
      final original = BoardState(
        arrows: [
          ArrowEntity(
            id: 'arrow1',
            direction: CardinalDirection.left,
            occupiedNodes: [
              Grid2DNodeId(row: 3, col: 3),
              Grid2DNodeId(row: 3, col: 2),
              Grid2DNodeId(row: 3, col: 1),
            ],
          ),
        ],
      );

      // Act
      final model = BoardStateMapper.toModel(original);
      final restored = BoardStateMapper.toEntity(model);

      // Assert
      expect(restored.arrowCount, equals(original.arrowCount));
      final originalArrow = original.getArrowById('arrow1')!;
      final restoredArrow = restored.getArrowById('arrow1')!;
      expect(restoredArrow.id, equals(originalArrow.id));
      expect(restoredArrow.direction, equals(originalArrow.direction));
      expect(restoredArrow.occupiedNodes.length, equals(originalArrow.occupiedNodes.length));
    });

    test('model_serialization_toMap_fromMap', () {
      // Arrange
      final model = BoardStateModel(
        arrows: [
          ArrowModel(
            id: 'arrow1',
            direction: 'right',
            occupiedNodes: [
              const NodeModel(row: 0, col: 0),
              const NodeModel(row: 0, col: 1),
            ],
          ),
        ],
      );

      // Act
      final map = model.toMap();
      final restored = BoardStateModel.fromMap(map);

      // Assert
      expect(restored.arrows.length, equals(1));
      expect(restored.arrows[0].id, equals('arrow1'));
    });
  });
}
