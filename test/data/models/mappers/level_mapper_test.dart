import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/board_size_model.dart';
import 'package:arrowconmango_front/features/game/data/models/board_state_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/arrow_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/board_state_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/level_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:test/test.dart';

void main() {
  const mapper = LevelMapper(BoardStateMapper(ArrowMapper()));

  group('LevelMapper', () {
    test('should_convert_level_model_to_entity', () {
      // Arrange
      final model = LevelModel(
        id: 1,
        name: 'Level 1',
        difficulty: 'Easy',
        boardSize: const BoardSizeModel(rows: 1, cols: 1),
        boardState: BoardStateModel(
          arrows: [
            ArrowModel(
              id: 'a',
              direction: 'right',
              nodes: const [NodeModel(row: 0, col: 0)],
            ),
          ],
        ),
      );

      // Act
      final entity = mapper.toEntity(model);

      // Assert
      expect(entity.levelId, equals(1));
      expect(entity.templateBoard.arrowCount, equals(1));
    });

    test('should_convert_level_entity_to_model', () {
      // Arrange
      final entity = Level(
        levelId: 5,
        templateBoard: BoardState(arrows: const []),
      );

      // Act
      final model = mapper.toModel(entity);

      // Assert
      expect(model.id, equals(5));
      expect(model.difficulty, equals('Easy'));
      expect(model.name, equals('Level 5'));
    });

    test('should_round_trip_model_through_entity', () {
      // Arrange
      final original = LevelModel(
        id: 1,
        name: 'Level 1',
        difficulty: 'Easy',
        boardSize: const BoardSizeModel(rows: 1, cols: 1),
        boardState: BoardStateModel(
          arrows: [
            ArrowModel(
              id: 'x',
              direction: 'up',
              nodes: const [NodeModel(row: 0, col: 0)],
            ),
          ],
        ),
      );

      // Act
      final entity = mapper.toEntity(original);
      final roundTripped = mapper.toModel(entity);

      // Assert
      expect(roundTripped.id, equals(original.id));
      expect(roundTripped.boardSize, equals(original.boardSize));
      expect(roundTripped.boardState, equals(original.boardState));
      expect(roundTripped.difficulty, equals(original.difficulty));
      expect(roundTripped.name, equals(original.name));
      expect(roundTripped, equals(original));
    });

    test('should_derive_hard_difficulty_for_high_level_ids', () {
      // Arrange
      final entity = Level(
        levelId: 12,
        templateBoard: BoardState(arrows: const []),
      );

      // Act
      final model = mapper.toModel(entity);

      // Assert
      expect(model.difficulty, equals('Hard'));
    });

    test('should_derive_board_size_from_entity_nodes', () {
      // Arrange
      final entity = Level(
        levelId: 3,
        templateBoard: BoardState(
          arrows: [
            ArrowEntity(
              id: 'a',
              direction: CardinalDirection.right,
              occupiedNodes: const [Grid2DNodeId(row: 0, col: 0)],
            ),
            ArrowEntity(
              id: 'b',
              direction: CardinalDirection.right,
              occupiedNodes: const [Grid2DNodeId(row: 4, col: 6)],
            ),
          ],
        ),
      );

      // Act
      final model = mapper.toModel(entity);

      // Assert
      expect(model.boardSize, equals(const BoardSizeModel(rows: 5, cols: 7)));
    });
  });
}
