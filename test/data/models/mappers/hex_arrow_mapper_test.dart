import 'package:arrowconmango_front/features/game/data/models/mappers/hex_arrow_mapper.dart';
import 'package:arrowconmango_front/features/game/data/topologies/hex_graph.dart';
import 'package:arrowconmango_front/features/game/data/topologies/hex_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/hex_direction.dart';
import 'package:test/test.dart';

void main() {
  final topology = HexTopology(radius: 3);

  group('HexArrowMapper.fromJson', () {
    test('should_walk_a_single_segment_trajectory_into_occupied_nodes', () {
      // Arrange
      final json = {
        'id': 'h1',
        'startNode': {'q': 0, 'r': 0},
        'trajectory': {
          'segments': [
            {'direction': 'se', 'length': 2},
          ],
        },
        'isSwitchable': false,
      };

      // Act
      final arrow = HexArrowMapper.fromJson(json, topology);

      // Assert
      expect(arrow.id, equals('h1'));
      expect(arrow.direction, equals(HexDirection.se));
      expect(
        arrow.occupiedNodes,
        equals(const [
          HexNodeId(q: 0, r: 0),
          HexNodeId(q: 1, r: 0),
        ]),
      );
    });

    test('should_walk_a_bent_multi_segment_trajectory', () {
      // Arrange — se 2, then n 1 (an "L"-shaped hex body)
      final json = {
        'id': 'h2',
        'startNode': {'q': 0, 'r': 0},
        'trajectory': {
          'segments': [
            {'direction': 'se', 'length': 2},
            {'direction': 'n', 'length': 1},
          ],
        },
        'isSwitchable': true,
      };

      // Act
      final arrow = HexArrowMapper.fromJson(json, topology);

      // Assert
      expect(arrow.direction, equals(HexDirection.n)); // final segment's direction
      expect(arrow.isSwitchable, isTrue);
      expect(
        arrow.occupiedNodes,
        equals(const [
          HexNodeId(q: 0, r: 0),
          HexNodeId(q: 1, r: 0),
          HexNodeId(q: 2, r: 0),
        ]),
      );
    });
  });

  group('HexArrowMapper.toJson', () {
    test('should_serialize_a_single_node_arrow_with_length_1_segment', () {
      // Arrange — length must be >= 1 (the backend rejects length 0), and
      // length 1 correctly round-trips through fromJson as a single push.
      const arrow = ArrowEntity(
        id: 'h3',
        direction: HexDirection.n,
        occupiedNodes: [HexNodeId(q: 1, r: -1)],
      );

      // Act
      final json = HexArrowMapper.toJson(arrow);

      // Assert
      expect(json['id'], equals('h3'));
      expect(json['startNode'], equals({'q': 1, 'r': -1}));
      final segments = (json['trajectory'] as Map)['segments'] as List;
      expect(segments, hasLength(1));
      expect(segments.first, equals({'direction': 'n', 'length': 1}));
    });

    test('should_group_consecutive_same_direction_steps_into_one_segment', () {
      // Arrange — a straight 3-cell body along se
      const arrow = ArrowEntity(
        id: 'h4',
        direction: HexDirection.se,
        occupiedNodes: [
          HexNodeId(q: 0, r: 0),
          HexNodeId(q: 1, r: 0),
          HexNodeId(q: 2, r: 0),
        ],
      );

      // Act
      final json = HexArrowMapper.toJson(arrow);

      // Assert — 3 pushed cells means length 3 (matches fromJson's "L
      // pushes per segment of length L").
      final segments = (json['trajectory'] as Map)['segments'] as List;
      expect(segments, equals([
        {'direction': 'se', 'length': 3},
      ]));
    });

    test('should_split_into_separate_segments_at_each_turn', () {
      // Arrange — bent body: se, se, then n (an "L" shape)
      const arrow = ArrowEntity(
        id: 'h5',
        direction: HexDirection.n,
        occupiedNodes: [
          HexNodeId(q: 0, r: 0),
          HexNodeId(q: 1, r: 0),
          HexNodeId(q: 2, r: 0),
          HexNodeId(q: 2, r: -1),
        ],
      );

      // Act
      final json = HexArrowMapper.toJson(arrow);

      // Assert — 4 pushed cells split se,se,n -> lengths sum to 4 (2 + 2),
      // the trailing segment absorbing the invisible final push.
      final segments = (json['trajectory'] as Map)['segments'] as List;
      expect(segments, equals([
        {'direction': 'se', 'length': 2},
        {'direction': 'n', 'length': 2},
      ]));
    });
  });

  group('round trip', () {
    test('should_preserve_a_straight_arrow_through_fromJson_and_toJson', () {
      final original = {
        'id': 'h6',
        'startNode': {'q': -1, 'r': 1},
        'trajectory': {
          'segments': [
            {'direction': 'se', 'length': 3},
          ],
        },
        'isSwitchable': false,
      };

      final arrow = HexArrowMapper.fromJson(original, topology);
      final restored = HexArrowMapper.toJson(arrow);

      expect(restored, equals(original));
    });

    test('should_preserve_a_bent_arrow_through_fromJson_and_toJson', () {
      final original = {
        'id': 'h7',
        'startNode': {'q': 0, 'r': 0},
        'trajectory': {
          'segments': [
            {'direction': 'se', 'length': 2},
            {'direction': 'n', 'length': 2},
          ],
        },
        'isSwitchable': false,
      };

      final arrow = HexArrowMapper.fromJson(original, topology);
      final restored = HexArrowMapper.toJson(arrow);

      expect(restored, equals(original));
    });
  });
}
