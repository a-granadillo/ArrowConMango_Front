import 'package:arrowconmango_front/features/game/data/level_definitions/cube_level_generator.dart';
import 'package:arrowconmango_front/features/game/data/level_definitions/cube_levels.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_3d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_geometry.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/services/collision_validator.dart';
import 'package:test/test.dart';

/// Greedily drains [board]: repeatedly removes any arrow whose exit path is
/// clear, until nothing can move. Returns the arrows still stuck (empty ⇒
/// the board was fully cleared, i.e. the level is solvable).
List<String> _drain(BoardState board, CollisionValidator validator) {
  var current = board;
  var madeProgress = true;
  while (madeProgress && !current.isEmpty) {
    madeProgress = false;
    for (final arrow in current.arrows) {
      if (validator.checkExit(arrow, current).canExit) {
        current = current.withoutArrow(arrow);
        madeProgress = true;
        break;
      }
    }
  }
  return current.arrows.map((a) => a.id).toList();
}

void main() {
  group('CubeLevelGenerator', () {
    test('should_produce_only_single_cell_arrows', () {
      for (final level in CubeLevels.all) {
        for (final arrow in level.templateBoard.arrows) {
          expect(
            arrow.occupiedNodes,
            hasLength(1),
            reason: 'Arrow ${arrow.id} in "${level.name}" is not single-cell',
          );
        }
      }
    });

    test('should_produce_unique_arrow_ids_within_each_level', () {
      for (final level in CubeLevels.all) {
        final ids = level.templateBoard.arrows.map((a) => a.id).toList();
        expect(ids.toSet(), hasLength(ids.length));
      }
    });

    test('should_keep_every_arrow_within_the_cube_bounds', () {
      for (final level in CubeLevels.all) {
        final geometry = level.geometry as BoardGeometry3D;
        for (final arrow in level.templateBoard.arrows) {
          final node = arrow.occupiedNodes.single as Cube3DNodeId;
          expect(node.x, inInclusiveRange(0, geometry.cols - 1));
          expect(node.y, inInclusiveRange(0, geometry.rows - 1));
          expect(node.z, inInclusiveRange(0, geometry.depth - 1));
        }
      }
    });

    test('should_reach_a_reasonably_dense_fill_ratio', () {
      for (final level in CubeLevels.all) {
        final geometry = level.geometry as BoardGeometry3D;
        final total = geometry.cols * geometry.rows * geometry.depth;
        final count = level.templateBoard.arrows.length;
        // The generator targets ~0.55-0.60; allow some slack for the ones
        // that don't hit the exact target within the seed budget.
        expect(
          count / total,
          greaterThan(0.35),
          reason: 'Level "${level.name}" is too sparse ($count/$total)',
        );
      }
    });

    test('should_be_solvable_for_every_catalogue_level', () {
      for (final level in CubeLevels.all) {
        final geometry = level.geometry as BoardGeometry3D;
        final validator = CollisionValidator(
          Grid3DTopology(
            width: geometry.cols,
            height: geometry.rows,
            depth: geometry.depth,
          ),
        );
        final stuck = _drain(level.templateBoard, validator);
        expect(
          stuck,
          isEmpty,
          reason: 'Level "${level.name}" is NOT solvable — stuck: $stuck',
        );
      }
    });

    test('should_have_an_immediately_exitable_arrow_for_every_catalogue_level', () {
      for (final level in CubeLevels.all) {
        final geometry = level.geometry as BoardGeometry3D;
        final validator = CollisionValidator(
          Grid3DTopology(
            width: geometry.cols,
            height: geometry.rows,
            depth: geometry.depth,
          ),
        );
        final board = level.templateBoard;
        final anyExitable = board.arrows.any(
          (a) => validator.checkExit(a, board).canExit,
        );
        expect(anyExitable, isTrue, reason: '"${level.name}" has no opening move');
      }
    });

    test('should_be_deterministic_for_a_fixed_seed', () {
      const config = CubeLevelConfig(width: 4, height: 4, depth: 4, fillRatio: 0.6);
      final a = CubeLevelGenerator.generate(id: -1, name: 'a', config: config, seed: 555);
      final b = CubeLevelGenerator.generate(id: -1, name: 'a', config: config, seed: 555);

      expect(a.templateBoard.arrows.length, b.templateBoard.arrows.length);
      final aIds = a.templateBoard.arrows.map((x) => x.id).toSet();
      final bIds = b.templateBoard.arrows.map((x) => x.id).toSet();
      expect(aIds, bIds);
    });

    test('should_be_solvable_for_several_fresh_seeds', () {
      for (final seed in [1, 42, 9999, 123456]) {
        final level = CubeLevels.generateFresh(seed);
        final geometry = level.geometry as BoardGeometry3D;
        final validator = CollisionValidator(
          Grid3DTopology(
            width: geometry.cols,
            height: geometry.rows,
            depth: geometry.depth,
          ),
        );
        final stuck = _drain(level.templateBoard, validator);
        expect(stuck, isEmpty, reason: 'Fresh seed $seed is NOT solvable — stuck: $stuck');
      }
    });
  });
}
