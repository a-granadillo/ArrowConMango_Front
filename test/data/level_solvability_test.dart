import 'package:arrowconmango_front/features/game/data/level_definitions/level_definitions.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/arrow_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/board_state_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/level_mapper.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/services/collision_validator.dart';
import 'package:test/test.dart';

/// Greedily drains [board]: repeatedly removes any arrow whose exit path is
/// clear, until nothing can move. Returns the arrows still stuck (empty ⇒ the
/// board was fully cleared, i.e. the level is solvable).
///
/// The exit rule is monotone (removing an arrow never blocks another), so this
/// greedy drain is an exact decision procedure: it clears the board iff a
/// solving order exists.
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
  // Topology must be at least as large as the biggest board so exit
  // trajectories resolve correctly (mirrors the production service locator).
  final validator = CollisionValidator(
    Grid2DTopology(rows: 12, cols: 12),
  );
  const mapper = LevelMapper(BoardStateMapper(ArrowMapper()));

  group('Level solvability', () {
    for (final level in LevelDefinitions.allLevels) {
      test('level_${level.id}_${level.name}_is_solvable', () {
        final entity = mapper.toEntity(level);
        final stuck = _drain(entity.templateBoard, validator);
        expect(
          stuck,
          isEmpty,
          reason: 'Level ${level.id} "${level.name}" is NOT solvable — '
              'these arrows can never exit: $stuck',
        );
      });
    }

    test('every_level_has_at_least_one_immediately_exitable_arrow', () {
      for (final level in LevelDefinitions.allLevels) {
        final board = mapper.toEntity(level).templateBoard;
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
}
