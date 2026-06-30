import 'package:test/test.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/level_mapper.dart';

void main() {
  group('LevelMapper', () {
    test('toModel_converts_entity_to_model', () {
      // Arrange
      final entity = Level(
        levelId: 1,
        templateBoard: BoardState(
          arrows: [
            ArrowEntity(
              id: 'arrow1',
              direction: CardinalDirection.right,
              occupiedNodes: [Grid2DNodeId(row: 0, col: 0)],
            ),
          ],
        ),
      );

      // Act
      final model = LevelMapper.toModel(entity);

      // Assert
      expect(model.levelId, equals(1));
      expect(model.templateBoard.arrows.length, equals(1));
    });

    test('toEntity_converts_model_to_entity', () {
      // Arrange
      final model = LevelModel(
        levelId: 5,
        templateBoard: BoardStateModel(
          arrows: [
            ArrowModel(
              id: 'arrow1',
              direction: 'down',
              occupiedNodes: [const NodeModel(row: 2, col: 2)],
            ),
          ],
        ),
      );

      // Act
      final entity = LevelMapper.toEntity(model);

      // Assert
      expect(entity.levelId, equals(5));
      expect(entity.templateBoard.arrowCount, equals(1));
    });

    test('roundtrip_entity_to_model_to_entity', () {
      // Arrange
      final original = Level(
        levelId: 10,
        templateBoard: BoardState(
          arrows: [
            ArrowEntity(
              id: 'arrow1',
              direction: CardinalDirection.up,
              occupiedNodes: [
                Grid2DNodeId(row: 4, col: 4),
                Grid2DNodeId(row: 3, col: 4),
              ],
            ),
          ],
        ),
      );

      // Act
      final model = LevelMapper.toModel(original);
      final restored = LevelMapper.toEntity(model);

      // Assert
      expect(restored.levelId, equals(original.levelId));
      expect(restored.templateBoard.arrowCount, equals(original.templateBoard.arrowCount));
    });

    test('model_serialization_toMap_fromMap', () {
      // Arrange
      final model = LevelModel(
        levelId: 15,
        templateBoard: BoardStateModel(
          arrows: [
            ArrowModel(
              id: 'arrow1',
              direction: 'left',
              occupiedNodes: [const NodeModel(row: 1, col: 1)],
            ),
          ],
        ),
      );

      // Act
      final map = model.toMap();
      final restored = LevelModel.fromMap(map);

      // Assert
      expect(restored.levelId, equals(15));
      expect(restored.templateBoard.arrows.length, equals(1));
    });
  });
}
