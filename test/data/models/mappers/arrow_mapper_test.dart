import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/arrow_trajectory.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/arrow_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';
import 'package:arrowconmango_front/features/game/data/models/trajectory_segment.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/node_id.dart';
import 'package:test/test.dart';

void main() {
  const mapper = ArrowMapper();

  group('ArrowMapper', () {
    test('should_convert_arrow_model_to_entity', () {
      // Arrange
      final model = ArrowModel(
        id: 'arrow-1',
        startNode: const NodeModel(row: 0, col: 0),
        trajectory: ArrowTrajectory(
          segments: [
            TrajectorySegment(direction: CardinalDirection.right, length: 2),
          ],
        ),
      );

      // Act
      final entity = mapper.toEntity(model);

      // Assert
      expect(entity.id, equals('arrow-1'));
      expect(entity.direction, equals(CardinalDirection.right));
      expect(
        entity.occupiedNodes,
        equals(const [
          Grid2DNodeId(row: 0, col: 0),
          Grid2DNodeId(row: 0, col: 1),
          Grid2DNodeId(row: 0, col: 2),
        ]),
      );
    });

    test('should_map_single_node_entity_to_model_with_zero_length', () {
      // Arrange
      final entity = ArrowEntity(
        id: 'arrow-2',
        direction: CardinalDirection.down,
        occupiedNodes: const [
          Grid2DNodeId(row: 2, col: 3),
        ],
      );

      // Act
      final model = mapper.toModel(entity);

      // Assert
      expect(model.id, equals('arrow-2'));
      expect(model.startNode, equals(const NodeModel(row: 2, col: 3)));
      expect(model.trajectory.segments, hasLength(1));
      expect(
        model.trajectory.segments.first,
        equals(
          const TrajectorySegment(direction: CardinalDirection.down, length: 0),
        ),
      );
    });

    test('should_round_trip_single_node_arrow_through_model', () {
      // Arrange
      final entity = ArrowEntity(
        id: 'arrow-2-single',
        direction: CardinalDirection.down,
        occupiedNodes: const [Grid2DNodeId(row: 2, col: 3)],
      );

      // Act
      final model = mapper.toModel(entity);
      final roundTripped = mapper.toEntity(model);

      // Assert
      expect(roundTripped.id, equals('arrow-2-single'));
      expect(roundTripped.direction, equals(CardinalDirection.down));
      expect(
        roundTripped.occupiedNodes,
        equals([const Grid2DNodeId(row: 2, col: 3)]),
      );
    });

    test('should_round_trip_model_through_entity', () {
      // Arrange
      final original = ArrowModel(
        id: 'arrow-3',
        startNode: const NodeModel(row: 1, col: 2),
        trajectory: ArrowTrajectory(
          segments: [
            TrajectorySegment(direction: CardinalDirection.left, length: 2),
          ],
        ),
      );

      // Act
      final roundTripped = mapper.toModel(mapper.toEntity(original));

      // Assert
      expect(roundTripped, equals(original));
    });

    test('should_round_trip_arrow_model_serialization', () {
      // Arrange
      final original = ArrowModel(
        id: 'arrow-4',
        startNode: const NodeModel(row: 0, col: 0),
        trajectory: ArrowTrajectory(
          segments: [
            TrajectorySegment(direction: CardinalDirection.up, length: 1),
          ],
        ),
      );

      // Act
      final json = original.toJson();
      final restored = ArrowModel.fromJson(json);

      // Assert
      expect(restored, equals(original));
    });

    test('should_handle_single_node_arrow', () {
      // Arrange
      final model = ArrowModel(
        id: 'arrow-5',
        startNode: const NodeModel(row: 0, col: 0),
        trajectory: ArrowTrajectory(
          segments: [
            TrajectorySegment(direction: CardinalDirection.up, length: 1),
          ],
        ),
      );

      // Act
      final entity = mapper.toEntity(model);
      final roundTripped = mapper.toModel(entity);

      // Assert
      expect(entity.occupiedNodes.length, equals(2)); // start + 1 segment
      expect(roundTripped, equals(model));
    });

    test('should_handle_multi_segment_trajectory', () {
      // Arrange - L-shaped arrow: right 2, then down 2
      final model = ArrowModel(
        id: 'arrow-6',
        startNode: const NodeModel(row: 0, col: 0),
        trajectory: ArrowTrajectory(
          segments: [
            TrajectorySegment(direction: CardinalDirection.right, length: 2),
            TrajectorySegment(direction: CardinalDirection.down, length: 2),
          ],
        ),
      );

      // Act
      final entity = mapper.toEntity(model);

      // Assert
      expect(entity.occupiedNodes.length, equals(5)); // start + 2 + 2
      expect(entity.direction, equals(CardinalDirection.down)); // final direction
      expect(
        entity.occupiedNodes,
        equals(const [
          Grid2DNodeId(row: 0, col: 0), // start
          Grid2DNodeId(row: 0, col: 1), // right 1
          Grid2DNodeId(row: 0, col: 2), // right 2
          Grid2DNodeId(row: 1, col: 2), // down 1
          Grid2DNodeId(row: 2, col: 2), // down 2
        ]),
      );
    });

    test('should_throw_with_clear_message_when_node_is_not_Grid2DNodeId', () {
      // Arrange — create an entity with a non-Grid2DNodeId node
      // This simulates a future topology (e.g., hexagonal) being passed to
      // the 2D-specific mapper.
      final entity = ArrowEntity(
        id: 'arrow-7',
        direction: CardinalDirection.up,
        occupiedNodes: [_FakeNodeId('hex-1')],
      );

      // Act / Assert
      expect(
        () => mapper.toModel(entity),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('ArrowMapper only supports Grid2DNodeId'),
          ),
        ),
      );
    });

    test('should_throw_with_clear_message_when_direction_is_not_cardinal', () {
      // Arrange
      final entity = ArrowEntity(
        id: 'arrow-8',
        direction: const _FakeDirection('hex-ne'),
        occupiedNodes: const [
          Grid2DNodeId(row: 0, col: 0),
          Grid2DNodeId(row: 0, col: 1),
        ],
      );

      // Act / Assert
      expect(
        () => mapper.toModel(entity),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('ArrowMapper only supports CardinalDirection'),
          ),
        ),
      );
    });
  });
}

/// Fake NodeId for testing non-Grid2D topologies.
class _FakeNodeId implements NodeId {
  final String value;
  const _FakeNodeId(this.value);

  @override
  String get key => value;

  @override
  List<Object?> get props => [value];

  @override
  bool get stringify => true;
}

class _FakeDirection implements Direction {
  final String value;
  const _FakeDirection(this.value);

  @override
  String get label => value;
}
