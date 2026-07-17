import 'package:arrowconmango_front/features/game/data/level_definitions/level_definitions.dart';
import 'package:arrowconmango_front/features/game/data/level_definitions/level_generator.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/arrow_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/board_state_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/level_mapper.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/services/collision_validator.dart';
import 'package:arrowconmango_front/features/game/domain/services/level_solver.dart';
import 'package:test/test.dart';

/// Thin wrapper matching this file's existing `List<String>` (empty ⇒
/// solvable) assertion style — the actual decision procedure is
/// [LevelSolver], shared with the level editor's "resolve before publish"
/// requirement and the generator's own acceptance check.
List<String> _drain(BoardState board, CollisionValidator validator) =>
    LevelSolver.solve(board, validator).stuckArrowIds;

void main() {
  // Topology must be at least as large as the biggest board so exit
  // trajectories resolve correctly (mirrors the production service locator).
  final validator = CollisionValidator(
    Grid2DTopology(rows: 12, cols: 12),
  );
  const mapper = LevelMapper(BoardStateMapper(ArrowMapper()));

  group('Level solvability', () {
    for (final level in LevelDefinitions.campaignLevels) {
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
      for (final level in LevelDefinitions.campaignLevels) {
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

  group('Endless/survival solvability', () {
    // Generate boards with the same configs used by generateEndless().
    // Each seed is a different level; we test that every one is solvable.
    for (final entry in [
      ('Easy', LevelConfig.easy, [1001, 2001, 3001, 4001, 5001]),
      ('Medium', LevelConfig.medium, [6001, 7001, 8001, 9001, 10001]),
      ('Hard', LevelConfig.hard, [11001, 12001, 13001, 14001, 15001]),
    ]) {
      final (diffLabel, config, seeds) = entry;
      for (final seed in seeds) {
        test('${diffLabel}_seed_${seed}_is_solvable', () {
          final level = LevelGenerator.generate(
            id: -seed,
            name: 'Test $diffLabel $seed',
            difficulty: diffLabel,
            config: config,
            seed: seed,
          );

          // Mapper + domain-level drain (same as campaign-level test).
          final entity = mapper.toEntity(level);
          final stuck = _drain(entity.templateBoard, validator);
          expect(
            stuck,
            isEmpty,
            reason: '$diffLabel seed $seed is NOT solvable — '
                '${stuck.length} arrows stuck: $stuck',
          );
        });
      }
    }

    test('every_survival_board_has_opening_move', () {
      for (final entry in [
        (LevelConfig.easy, [1001, 2001]),
        (LevelConfig.medium, [6001, 7001]),
        (LevelConfig.hard, [11001, 12001]),
      ]) {
        final (config, seeds) = entry;
        for (final seed in seeds) {
          final level = LevelGenerator.generate(
            id: -seed,
            name: 'Test $seed',
            difficulty: 'Test',
            config: config,
            seed: seed,
          );
          final board = mapper.toEntity(level).templateBoard;
          final anyExitable = board.arrows.any(
            (a) => validator.checkExit(a, board).canExit,
          );
          expect(
            anyExitable,
            isTrue,
            reason: 'Seed $seed has no opening move',
          );
        }
      }
    });
  });
}
