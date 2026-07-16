import 'package:arrowconmango_front/features/game/data/level_definitions/level_generator.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/arrow_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/board_state_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/level_mapper.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_geometry.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/services/collision_validator.dart';
import 'package:test/test.dart';

const _mapper = LevelMapper(BoardStateMapper(ArrowMapper()));

/// Greedily drains [board] to verify it is solvable.
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
  group('LevelGenerator.generate', () {
    test('should_be_deterministic_for_fixed_seed_and_config', () {
      const config = LevelConfig.easy;
      final a = LevelGenerator.generate(
        id: 1,
        name: 'Test',
        difficulty: 'Easy',
        config: config,
        seed: 12345,
      );
      final b = LevelGenerator.generate(
        id: 1,
        name: 'Test',
        difficulty: 'Easy',
        config: config,
        seed: 12345,
      );

      // IDs come from a process-wide sequence, so compare structural identity,
      // and strip ID prefixes (e.g. 'a1491' vs 'a2991') when comparing arrows.
      expect(a.id, equals(b.id));
      expect(a.name, equals(b.name));
      expect(a.difficulty, equals(b.difficulty));
      expect(a.boardSize, equals(b.boardSize));
      
      final aStartNodes = a.boardState.arrows.map((arrow) => arrow.startNode).toList();
      final bStartNodes = b.boardState.arrows.map((arrow) => arrow.startNode).toList();
      expect(aStartNodes, equals(bStartNodes));

      final aTrajectories = a.boardState.arrows.map((arrow) => arrow.trajectory).toList();
      final bTrajectories = b.boardState.arrows.map((arrow) => arrow.trajectory).toList();
      expect(aTrajectories, equals(bTrajectories));
    });

    test('should_produce_different_boards_for_different_campaign_ids', () {
      const config = LevelConfig.easy;
      final a = LevelGenerator.generate(
        id: 1,
        name: 'Level 1',
        difficulty: 'Easy',
        config: config,
        seed: 1,
      );
      final b = LevelGenerator.generate(
        id: 2,
        name: 'Level 2',
        difficulty: 'Easy',
        config: config,
        seed: 2,
      );

      expect(a.id, equals(1));
      expect(b.id, equals(2));
      // Different seeds should very likely produce a different arrow layout.
      expect(
        a.boardState.arrows.map((arrow) => arrow.startNode),
        isNot(equals(b.boardState.arrows.map((arrow) => arrow.startNode))),
      );
    });

    test('should_return_expected_board_size', () {
      final level = LevelGenerator.generate(
        id: 1,
        name: 'Medium',
        difficulty: 'Medium',
        config: LevelConfig.medium,
        seed: 42,
      );

      expect(level.boardSize.rows, equals(LevelConfig.medium.rows));
      expect(level.boardSize.cols, equals(LevelConfig.medium.cols));
    });

    test('should_place_a_sensible_number_of_arrows', () {
      final level = LevelGenerator.generate(
        id: 1,
        name: 'Easy',
        difficulty: 'Easy',
        config: LevelConfig.easy,
        seed: 123,
      );

      // The generator may stop early when the board becomes too crowded;
      // we only require a non-empty solvable board within requested bounds.
      expect(level.boardState.arrows.length, greaterThan(0));
      expect(
        level.boardState.arrows.length,
        lessThanOrEqualTo(LevelConfig.easy.arrowCount),
      );
    });

    test('should_keep_all_arrows_inside_the_board', () {
      final level = LevelGenerator.generate(
        id: 1,
        name: 'Hard',
        difficulty: 'Hard',
        config: LevelConfig.hard,
        seed: 99,
      );

      final rows = level.boardSize.rows;
      final cols = level.boardSize.cols;
      for (final arrow in level.boardState.arrows) {
        final startNode = arrow.startNode;
        final trajectoryCells = arrow.trajectory.toNodes(
          Grid2DNodeId(row: startNode.row, col: startNode.col),
        );
        for (final cell in trajectoryCells) {
          if (cell is! Grid2DNodeId) continue;
          expect(
            cell.row,
            inInclusiveRange(0, rows - 1),
            reason: 'Arrow ${arrow.id} has a row outside the board',
          );
          expect(
            cell.col,
            inInclusiveRange(0, cols - 1),
            reason: 'Arrow ${arrow.id} has a col outside the board',
          );
        }
      }
    });

    test('should_use_unique_arrow_ids_within_each_level', () {
      final level = LevelGenerator.generate(
        id: 1,
        name: 'Medium',
        difficulty: 'Medium',
        config: LevelConfig.medium,
        seed: 7,
      );

      final ids = level.boardState.arrows.map((a) => a.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('should_be_solvable_for_configured_easy_seed', () {
      final model = LevelGenerator.generate(
        id: 1,
        name: 'Easy',
        difficulty: 'Easy',
        config: LevelConfig.easy,
        seed: 123,
      );
      final level = _mapper.toEntity(model);
      final geometry = level.geometry as BoardGeometry2D;
      final validator = CollisionValidator(
        Grid2DTopology(
          rows: geometry.rows,
          cols: geometry.cols,
        ),
      );
      final stuck = _drain(level.templateBoard, validator);

      expect(stuck, isEmpty);
    });

    test('should_have_an_opening_move_for_configured_seed', () {
      final model = LevelGenerator.generate(
        id: 1,
        name: 'Easy',
        difficulty: 'Easy',
        config: LevelConfig.easy,
        seed: 456,
      );
      final level = _mapper.toEntity(model);
      final geometry = level.geometry as BoardGeometry2D;
      final validator = CollisionValidator(
        Grid2DTopology(
          rows: geometry.rows,
          cols: geometry.cols,
        ),
      );
      final board = level.templateBoard;
      final anyExitable = board.arrows.any(
        (a) => validator.checkExit(a, board).canExit,
      );

      expect(anyExitable, isTrue);
    });

    test('should_produce_switchable_arrows_when_ratio_is_non_zero', () {
      const config = LevelConfig.medium;
      final level = LevelGenerator.generate(
        id: 1,
        name: 'Medium',
        difficulty: 'Medium',
        config: config,
        seed: 10,
      );

      final switchableCount = level.boardState.arrows
          .where((arrow) => arrow.isSwitchable)
          .length;
      expect(switchableCount, greaterThan(0));
    });
  });
}
