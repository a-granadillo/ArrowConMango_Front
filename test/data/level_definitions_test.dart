import 'package:arrowconmango_front/features/game/data/level_definitions/level_definitions.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/arrow_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/board_state_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/level_mapper.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:test/test.dart';

void main() {
  group('LevelDefinitions', () {
    test('should_contain_all_15_levels', () {
      expect(LevelDefinitions.allLevels, hasLength(15));
    });

    test('should_have_unique_ids_from_1_to_15', () {
      final ids = LevelDefinitions.allLevels.map((l) => l.id).toList();
      expect(ids.toSet(), hasLength(15));
      expect(ids, containsAll(List.generate(15, (i) => i + 1)));
    });

    test('should_have_non_empty_names', () {
      for (final level in LevelDefinitions.allLevels) {
        expect(level.name, isNotEmpty);
      }
    });

    test('should_have_valid_difficulty_labels', () {
      for (final level in LevelDefinitions.allLevels) {
        expect(
          level.difficulty,
          isIn(['Easy', 'Medium', 'Hard']),
          reason: 'Level ${level.id} has invalid difficulty',
        );
      }
    });

    test('should_have_board_size_defined_for_all_levels', () {
      for (final level in LevelDefinitions.allLevels) {
        expect(
          level.boardSize.rows,
          greaterThan(0),
          reason: 'Level ${level.id} has invalid boardSize.rows',
        );
        expect(
          level.boardSize.cols,
          greaterThan(0),
          reason: 'Level ${level.id} has invalid boardSize.cols',
        );
      }
    });

    test('should_have_all_arrow_nodes_within_board_bounds', () {
      for (final level in LevelDefinitions.allLevels) {
        for (final arrow in level.boardState.arrows) {
          final nodes = arrow.trajectory.toNodes(
            Grid2DNodeId(
              row: arrow.startNode.row,
              col: arrow.startNode.col,
            ),
          );
          for (final node in nodes) {
            if (node is! Grid2DNodeId) continue;
            expect(
              node.row,
              inInclusiveRange(0, level.boardSize.rows - 1),
              reason:
                  'Level ${level.id} arrow ${arrow.id} node row ${node.row} is out of bounds',
            );
            expect(
              node.col,
              inInclusiveRange(0, level.boardSize.cols - 1),
              reason:
                  'Level ${level.id} arrow ${arrow.id} node col ${node.col} is out of bounds',
            );
          }
        }
      }
    });

    test('should_map_to_domain_without_overlapping_arrows', () {
      const mapper = LevelMapper(BoardStateMapper(ArrowMapper()));

      for (final level in LevelDefinitions.allLevels) {
        expect(
          () => mapper.toEntity(level),
          returnsNormally,
          reason: 'Level ${level.id} has overlapping arrows or invalid nodes',
        );
      }
    });

    test('should_round_trip_through_json', () {
      for (final level in LevelDefinitions.allLevels) {
        final json = level.toJson();
        final restored = LevelModel.fromJson(json);
        expect(restored, equals(level));
      }
    });

    test('should_preserve_board_size_through_domain_round_trip', () {
      const mapper = LevelMapper(BoardStateMapper(ArrowMapper()));

      for (final level in LevelDefinitions.allLevels) {
        final entity = mapper.toEntity(level);
        final restored = mapper.toModel(entity);

        expect(
          restored.boardSize,
          equals(level.boardSize),
          reason:
              'Level ${level.id} (${level.name}) boardSize not stable through round-trip',
        );
      }
    });
  });

  group('Easy levels', () {
    test('should_have_6_to_10_arrows', () {
      for (final level in LevelDefinitions.easyLevels) {
        final count = level.boardState.arrows.length;
        expect(
          count,
          inInclusiveRange(6, 10),
          reason: 'Easy level ${level.id} ($count arrows) is out of range',
        );
      }
    });
  });

  group('Medium levels', () {
    test('should_have_10_to_14_arrows', () {
      for (final level in LevelDefinitions.mediumLevels) {
        final count = level.boardState.arrows.length;
        expect(
          count,
          inInclusiveRange(10, 14),
          reason: 'Medium level ${level.id} ($count arrows) is out of range',
        );
      }
    });
  });

  group('Hard levels', () {
    test('should_have_14_to_20_arrows', () {
      for (final level in LevelDefinitions.hardLevels) {
        final count = level.boardState.arrows.length;
        expect(
          count,
          inInclusiveRange(14, 20),
          reason: 'Hard level ${level.id} ($count arrows) is out of range',
        );
      }
    });
  });

  group('Arrow structure', () {
    test('every_arrow_should_have_at_least_1_node', () {
      for (final level in LevelDefinitions.allLevels) {
        for (final arrow in level.boardState.arrows) {
          final nodes = arrow.trajectory.toNodes(
            Grid2DNodeId(
              row: arrow.startNode.row,
              col: arrow.startNode.col,
            ),
          );
          expect(
            nodes.length,
            greaterThanOrEqualTo(1),
            reason: 'Level ${level.id} arrow ${arrow.id} has no nodes',
          );
        }
      }
    });

    test('every_arrow_should_have_a_valid_trajectory', () {
      for (final level in LevelDefinitions.allLevels) {
        for (final arrow in level.boardState.arrows) {
          for (final segment in arrow.trajectory.segments) {
            expect(
              ['up', 'down', 'left', 'right'],
              contains(segment.direction.name),
              reason: 'Level ${level.id} arrow ${arrow.id} has invalid direction',
            );
          }
        }
      }
    });

    test('arrow_ids_should_be_unique_within_each_level', () {
      for (final level in LevelDefinitions.allLevels) {
        final ids = level.boardState.arrows.map((a) => a.id).toList();
        expect(ids.toSet(), hasLength(ids.length));
      }
    });
  });
}
