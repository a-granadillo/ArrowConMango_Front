import 'package:arrowconmango_front/features/game/data/level_definitions/level_definitions_3d.dart';
import 'package:arrowconmango_front/features/game/data/level_definitions/level_generator_3d.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_3d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/services/collision_validator.dart';
import 'package:test/test.dart';

/// Greedily drains [board]: repeatedly removes any arrow whose exit path is
/// clear, until nothing can move. Returns the arrows still stuck (empty ⇒ the
/// board was fully cleared, i.e. the level is solvable).
///
/// Mirrors `test/data/level_solvability_test.dart`'s `_drain`, applied to 3D
/// domain entities directly (no model/mapper layer for 3D levels yet).
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
  // Topology must be at least as large as the biggest 3D board so exit
  // trajectories resolve correctly (mirrors the production service locator's
  // shared-topology pattern for 2D).
  final validator = CollisionValidator(
    Grid3DTopology(width: 7, height: 7, depth: 5),
  );

  group('3D level solvability', () {
    for (final level in LevelDefinitions3D.campaignLevels3D) {
      test('level_${level.levelId}_${level.name}_is_solvable', () {
        final stuck = _drain(level.templateBoard, validator);
        expect(
          stuck,
          isEmpty,
          reason: 'Level ${level.levelId} "${level.name}" is NOT solvable — '
              'these arrows can never exit: $stuck',
        );
      });
    }

    test('every_3d_level_has_at_least_one_immediately_exitable_arrow', () {
      for (final level in LevelDefinitions3D.campaignLevels3D) {
        final board = level.templateBoard;
        final anyExitable = board.arrows.any(
          (a) => validator.checkExit(a, board).canExit,
        );
        expect(
          anyExitable,
          isTrue,
          reason: 'Level ${level.levelId} has no opening move',
        );
      }
    });
  });

  group('3D endless generation solvability', () {
    // Generate ad-hoc boards with configs beyond the fixed campaign catalogue
    // to confirm LevelGenerator3D itself (not just the 10 fixed seeds) always
    // produces solvable output.
    for (final seed in [31101, 32101, 33101]) {
      test('adhoc_seed_${seed}_is_solvable', () {
        final level = LevelGenerator3D.generate(
          id: -seed,
          name: 'Test $seed',
          config: const LevelConfig3D(
            width: 6,
            height: 6,
            depth: 4,
            arrowCount: 15,
            straightRatio: 0.3,
            lShapeRatio: 0.4,
            zShapeRatio: 0.3,
            minSegmentLength: 1,
            maxSegmentLength: 3,
            minGraphDepth: 3,
          ),
          seed: seed,
        );

        final stuck = _drain(level.templateBoard, validator);
        expect(
          stuck,
          isEmpty,
          reason: 'Seed $seed is NOT solvable — ${stuck.length} arrows stuck: $stuck',
        );
      });
    }
  });
}
