import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:arrowconmango_front/features/game/domain/services/collision_validator.dart';
import 'package:arrowconmango_front/features/game/domain/services/level_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final validator = CollisionValidator(Grid2DTopology(rows: 4, cols: 4));

  test('should_be_solvable_when_every_arrow_has_a_clear_path', () {
    // Two arrows pointing right, on separate rows — nothing blocks either.
    final board = BoardState(arrows: const [
      ArrowEntity(
        id: 'a1',
        direction: CardinalDirection.right,
        occupiedNodes: [Grid2DNodeId(row: 0, col: 0)],
      ),
      ArrowEntity(
        id: 'a2',
        direction: CardinalDirection.right,
        occupiedNodes: [Grid2DNodeId(row: 1, col: 0)],
      ),
    ]);

    final result = LevelSolver.solve(board, validator);

    expect(result.isSolvable, isTrue);
    expect(result.stuckArrowIds, isEmpty);
    expect(LevelSolver.isSolvable(board, validator), isTrue);
  });

  test('should_be_unsolvable_when_two_arrows_block_each_other', () {
    // a1 points right into a2's tail; a2 points left into a1's tail — a
    // deadlock neither can escape.
    final board = BoardState(arrows: const [
      ArrowEntity(
        id: 'a1',
        direction: CardinalDirection.right,
        occupiedNodes: [Grid2DNodeId(row: 0, col: 0)],
      ),
      ArrowEntity(
        id: 'a2',
        direction: CardinalDirection.left,
        occupiedNodes: [Grid2DNodeId(row: 0, col: 1)],
      ),
    ]);

    final result = LevelSolver.solve(board, validator);

    expect(result.isSolvable, isFalse);
    expect(result.stuckArrowIds, unorderedEquals(['a1', 'a2']));
    expect(LevelSolver.isSolvable(board, validator), isFalse);
  });

  test('should_solve_a_chain_by_removing_arrows_in_the_right_order', () {
    // a2 blocks a1's exit; removing a2 first (it has a clear path) frees a1.
    final board = BoardState(arrows: const [
      ArrowEntity(
        id: 'a1',
        direction: CardinalDirection.right,
        occupiedNodes: [Grid2DNodeId(row: 0, col: 0)],
      ),
      ArrowEntity(
        id: 'a2',
        direction: CardinalDirection.down,
        occupiedNodes: [Grid2DNodeId(row: 0, col: 1)],
      ),
    ]);

    expect(LevelSolver.isSolvable(board, validator), isTrue);
  });

  test('should_be_trivially_solvable_for_an_empty_board', () {
    final board = BoardState(arrows: const []);
    expect(LevelSolver.isSolvable(board, validator), isTrue);
  });
}
