import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/arrow_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/node_id.dart';
import 'package:test/test.dart';

void main() {
  const mapper = ArrowMapper();

  group('ArrowMapper', () {
    test('should_convert_arrow_model_to_entity', () {
      // Arrange
      final model = ArrowModel(
        id: 'arrow-1',
        direction: 'right',
        nodes: const [NodeModel(row: 0, col: 0), NodeModel(row: 0, col: 1)],
      );

      // Act
      final entity = mapper.toEntity(model);

      // Assert
      expect(entity.id, equals('arrow-1'));
      expect(entity.direction, equals(CardinalDirection.right));
      expect(
        entity.occupiedNodes,
        equals(const [Grid2DNodeId(row: 0, col: 0), Grid2DNodeId(row: 0, col: 1)]),
      );
    });

    test('should_convert_arrow_entity_to_model', () {
      // Arrange
      final entity = ArrowEntity(
        id: 'arrow-2',
        direction: CardinalDirection.down,
        occupiedNodes: const [Grid2DNodeId(row: 2, col: 3)],
      );

      // Act
      final model = mapper.toModel(entity);

      // Assert
      expect(model.id, equals('arrow-2'));
      expect(model.direction, equals('down'));
      expect(model.nodes, equals(const [NodeModel(row: 2, col: 3)]));
    });

    test('should_round_trip_model_through_entity', () {
      // Arrange
      final original = ArrowModel(
        id: 'arrow-3',
        direction: 'left',
        nodes: const [NodeModel(row: 1, col: 2), NodeModel(row: 1, col: 1)],
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
        direction: 'up',
        nodes: const [NodeModel(row: 0, col: 0)],
      );

      // Act
      final json = original.toJson();
      final restored = ArrowModel.fromJson(json);

      // Assert
      expect(restored, equals(original));
    });

    test('should_handle_empty_occupied_nodes', () {
      // Arrange
      final model = ArrowModel(
        id: 'arrow-5',
        direction: 'up',
        nodes: const [],
      );

      // Act
      final entity = mapper.toEntity(model);
      final roundTripped = mapper.toModel(entity);

      // Assert
      expect(entity.occupiedNodes, isEmpty);
      expect(roundTripped.nodes, isEmpty);
      expect(roundTripped, equals(model));
    });

    test('should_throw_when_direction_label_is_unknown', () {
      // Arrange
      final model = ArrowModel(
        id: 'arrow-6',
        direction: 'diagonal',
        nodes: const [NodeModel(row: 0, col: 0)],
      );

      // Act / Assert
      expect(() => mapper.toEntity(model), throwsArgumentError);
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
