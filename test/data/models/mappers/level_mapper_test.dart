import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/arrow_trajectory.dart';
import 'package:arrowconmango_front/features/game/data/models/board_size_model.dart';
import 'package:arrowconmango_front/features/game/data/models/board_state_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/arrow_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/board_state_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/level_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';
import 'package:arrowconmango_front/features/game/data/models/trajectory_segment.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_geometry.dart';
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
        boardSize: const BoardSizeModel(rows: 7, cols: 7),
        boardState: BoardStateModel(
          arrows: [
            ArrowModel(
              id: 'a',
              startNode: const NodeModel(row: 0, col: 0),
              trajectory: ArrowTrajectory(
                segments: [
                  TrajectorySegment(direction: CardinalDirection.right, length: 1),
                ],
              ),
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
        geometry: const BoardGeometry2D(rows: 7, cols: 7),
        templateBoard: BoardState(arrows: const []),
      );

      // Act
      final model = mapper.toModel(entity);

      // Assert
      expect(model.id, equals(5));
      expect(model.difficulty, equals('Easy'));
      expect(model.name, equals('Level 5'));
      expect(model.boardSize.rows, equals(7));
      expect(model.boardSize.cols, equals(7));
    });

    test('should_round_trip_model_through_entity', () {
      // Arrange
      final original = LevelModel(
        id: 1,
        name: 'Level 1',
        difficulty: 'Easy',
        boardSize: const BoardSizeModel(rows: 7, cols: 7),
        boardState: BoardStateModel(
          arrows: [
            ArrowModel(
              id: 'x',
              startNode: const NodeModel(row: 0, col: 0),
              trajectory: ArrowTrajectory(
                segments: [
                  TrajectorySegment(direction: CardinalDirection.up, length: 1),
                ],
              ),
            ),
          ],
        ),
      );

      // Act
      final entity = mapper.toEntity(original);
      final roundTripped = mapper.toModel(entity);

      // Assert
      expect(roundTripped.id, equals(original.id));
      expect(roundTripped.boardState, equals(original.boardState));
      expect(roundTripped.difficulty, equals(original.difficulty));
      expect(roundTripped.name, equals(original.name));
      expect(roundTripped, equals(original));
    });

    test('should_derive_hard_difficulty_for_high_level_ids', () {
      // Arrange
      final entity = Level(
        levelId: 12,
        geometry: const BoardGeometry2D(rows: 7, cols: 7),
        templateBoard: BoardState(arrows: const []),
      );

      // Act
      final model = mapper.toModel(entity);

      // Assert
      expect(model.difficulty, equals('Hard'));
    });

    test('should_deserialize_legacy_json_with_flat_rows_and_cols_correctly', () {
      // Arrange
      final legacyJson = {
        'id': 1,
        'name': 'Legacy Level',
        'difficulty': 'Easy',
        'rows': 5,
        'cols': 6,
        'boardState': {
          'arrows': <Map<String, dynamic>>[]
        }
      };

      // Act
      final model = LevelModel.fromJson(legacyJson);
      final entity = mapper.toEntity(model);

      // Assert
      expect(entity.levelId, equals(1));
      expect(entity.rows, equals(5));
      expect(entity.cols, equals(6));
      expect(entity.geometry, isA<BoardGeometry2D>());
    });
  });
}
