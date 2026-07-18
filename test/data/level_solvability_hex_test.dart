import 'package:arrowconmango_front/features/game/data/level_definitions/hex_level_generator.dart';
import 'package:arrowconmango_front/features/game/data/level_definitions/hex_levels.dart';
import 'package:arrowconmango_front/features/game/data/topologies/hex_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/services/collision_validator.dart';
import 'package:test/test.dart';

/// Greedily drains [board]: repeatedly removes any arrow whose exit path is
/// clear, until nothing can move. Returns the arrows still stuck (empty ⇒ the
/// board was fully cleared, i.e. the level is solvable).
///
/// Mirrors `test/data/level_solvability_3d_test.dart`'s `_drain`.
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
  // Topology must be at least as large as the biggest hex board so exit
  // trajectories resolve correctly (mirrors the production service locator's
  // shared-topology pattern; the widest catalogue level has radius 4).
  final validator = CollisionValidator(HexTopology(radius: 6));

  group('Hexagonal level solvability', () {
    for (final level in HexLevels.all) {
      test('level_${level.id}_is_solvable', () {
        final stuck = _drain(level.templateBoard, validator);
        expect(
          stuck,
          isEmpty,
          reason: 'Level ${level.id} "${level.name}" is NOT solvable — '
              'these arrows can never exit: $stuck',
        );
      });
    }

    test('every_arrow_in_every_hex_level_spans_at_least_2_hexagons', () {
      // A 1-cell arrow is barely a dot on screen — its shape (and thus which
      // way it will slide) is unreadable. The generator enforces this via
      // HexLevelConfig.minArrowLength (default 2); this asserts the whole
      // shipped catalogue actually honors it.
      for (final level in HexLevels.all) {
        for (final arrow in level.templateBoard.arrows) {
          expect(
            arrow.length,
            greaterThanOrEqualTo(2),
            reason: 'Arrow "${arrow.id}" in level ${level.id} only spans '
                '${arrow.length} hexagon(s)',
          );
        }
      }
    });

    test('every_hex_level_has_at_least_one_immediately_exitable_arrow', () {
      for (final level in HexLevels.all) {
        final board = level.templateBoard;
        final anyExitable = board.arrows.any(
          (a) => validator.checkExit(a, board).canExit,
        );
        expect(
          anyExitable,
          isTrue,
          reason: 'Level ${level.id} has no opening move',
        );
      }
    });
  });

  group('Hexagonal ad-hoc generation solvability', () {
    // Generate ad-hoc boards beyond the fixed catalogue to confirm
    // HexLevelGenerator itself (not just the 5 fixed seeds) always produces
    // solvable output.
    for (final seed in [71101, 72101, 73101]) {
      test('adhoc_seed_${seed}_is_solvable', () {
        final level = HexLevelGenerator.generate(
          id: 'test-$seed',
          name: 'Test $seed',
          difficulty: 'Medium',
          config: const HexLevelConfig(
            radius: 3,
            fillRatio: 0.6,
            maxArrowLength: 3,
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
