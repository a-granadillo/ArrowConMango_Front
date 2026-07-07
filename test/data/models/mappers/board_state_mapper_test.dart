import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/arrow_trajectory.dart';
import 'package:arrowconmango_front/features/game/data/models/board_state_model.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/arrow_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/board_state_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';
import 'package:arrowconmango_front/features/game/data/models/trajectory_segment.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:test/test.dart';

void main() {
  const mapper = BoardStateMapper(ArrowMapper());

  group('BoardStateMapper', () {
    test('should_convert_board_state_model_to_entity', () {
      // Arrange
      final model = BoardStateModel(
        arrows: [
          ArrowModel(
            id: 'a',
            startNode: const NodeModel(row: 0, col: 0),
            trajectory: const ArrowTrajectory(
              segments: [
                TrajectorySegment(direction: CardinalDirection.right, length: 2),
              ],
            ),
          ),
        ],
      );

      // Act
      final entity = mapper.toEntity(model);

      // Assert
      expect(entity.arrowCount, equals(1));
      expect(entity.getArrowById('a'), isNotNull);
    });

    test('should_convert_board_state_entity_to_model', () {
      // Arrange
      final entity = BoardState(arrows: const []);

      // Act
      final model = mapper.toModel(entity);

      // Assert
      expect(model.arrows, isEmpty);
    });

    test('should_round_trip_model_through_entity', () {
      // Arrange
      final original = BoardStateModel(
        arrows: [
          ArrowModel(
            id: 'b',
            startNode: const NodeModel(row: 1, col: 1),
            trajectory: const ArrowTrajectory(
              segments: [
                TrajectorySegment(direction: CardinalDirection.down, length: 1),
              ],
            ),
          ),
          ArrowModel(
            id: 'c',
            startNode: const NodeModel(row: 2, col: 2),
            trajectory: const ArrowTrajectory(
              segments: [
                TrajectorySegment(direction: CardinalDirection.left, length: 2),
              ],
            ),
          ),
        ],
      );

      // Act
      final roundTripped = mapper.toModel(mapper.toEntity(original));

      // Assert
      expect(roundTripped, equals(original));
    });

    test('should_handle_empty_arrows_list', () {
      // Arrange
      final original = const BoardStateModel(arrows: []);

      // Act
      final entity = mapper.toEntity(original);
      final roundTripped = mapper.toModel(entity);

      // Assert
      expect(entity.isEmpty, isTrue);
      expect(roundTripped.arrows, isEmpty);
      expect(roundTripped, equals(original));
    });
  });
}
