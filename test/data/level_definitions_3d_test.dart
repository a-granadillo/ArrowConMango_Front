import 'package:arrowconmango_front/features/game/data/level_definitions/level_definitions_3d.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_3d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_geometry.dart';
import 'package:test/test.dart';

void main() {
  group('LevelDefinitions3D', () {
    test('should_contain_10_levels', () {
      expect(LevelDefinitions3D.campaignLevels3D, hasLength(10));
    });

    test('should_have_unique_ids_from_16_to_25', () {
      final ids =
          LevelDefinitions3D.campaignLevels3D.map((l) => l.levelId).toList();
      expect(ids.toSet(), hasLength(10));
      expect(ids, containsAll(List.generate(10, (i) => i + 16)));
    });

    test('should_have_non_empty_names', () {
      for (final level in LevelDefinitions3D.campaignLevels3D) {
        expect(level.name, isNotEmpty);
      }
    });

    test('should_use_3D_board_geometry', () {
      for (final level in LevelDefinitions3D.campaignLevels3D) {
        expect(level.geometry, isA<BoardGeometry3D>());
      }
    });

    test('should_have_all_arrow_nodes_within_board_bounds', () {
      for (final level in LevelDefinitions3D.campaignLevels3D) {
        final geometry = level.geometry as BoardGeometry3D;
        for (final arrow in level.templateBoard.arrows) {
          for (final node in arrow.occupiedNodes) {
            final cube = node as Cube3DNodeId;
            expect(
              cube.x,
              inInclusiveRange(0, geometry.cols - 1),
              reason: 'Level ${level.levelId} arrow ${arrow.id} x out of bounds',
            );
            expect(
              cube.y,
              inInclusiveRange(0, geometry.rows - 1),
              reason: 'Level ${level.levelId} arrow ${arrow.id} y out of bounds',
            );
            expect(
              cube.z,
              inInclusiveRange(0, geometry.depth - 1),
              reason: 'Level ${level.levelId} arrow ${arrow.id} z out of bounds',
            );
          }
        }
      }
    });

    test('arrow_ids_should_be_unique_within_each_level', () {
      for (final level in LevelDefinitions3D.campaignLevels3D) {
        final ids = level.templateBoard.arrows.map((a) => a.id).toList();
        expect(ids.toSet(), hasLength(ids.length));
      }
    });

    test('every_arrow_should_have_at_least_2_nodes', () {
      for (final level in LevelDefinitions3D.campaignLevels3D) {
        for (final arrow in level.templateBoard.arrows) {
          expect(
            arrow.occupiedNodes.length,
            greaterThanOrEqualTo(2),
            reason: 'Level ${level.levelId} arrow ${arrow.id} has too few nodes',
          );
        }
      }
    });

    test('should_get_level_by_id', () {
      final level = LevelDefinitions3D.getById(16);
      expect(level, isNotNull);
      expect(level!.levelId, equals(16));
    });

    test('should_return_null_for_unknown_id', () {
      expect(LevelDefinitions3D.getById(999), isNull);
    });
  });
}
