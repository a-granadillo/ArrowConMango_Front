import 'package:test/test.dart';

import 'package:arrowconmango_front/features/game/domain/entities/arrow_cell.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cell.dart';
import 'package:arrowconmango_front/features/game/domain/entities/direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/empty_cell.dart';
import 'package:arrowconmango_front/features/game/domain/entities/exit_cell.dart';
import 'package:arrowconmango_front/features/game/domain/entities/path_step.dart';
import 'package:arrowconmango_front/features/game/domain/entities/position.dart';
import 'package:arrowconmango_front/features/game/domain/entities/wall_cell.dart';

void main() {
  group('PathStep', () {
    test(
      'should_expose_outcome_and_direction_when_created',
      () {
        // Arrange
        const expectedOutcome = PathOutcome.continuePath;
        const expectedDirection = Direction.right;

        // Act
        const step = PathStep(
          outcome: expectedOutcome,
          nextDirection: expectedDirection,
        );

        // Assert
        expect(step.outcome, equals(expectedOutcome));
        expect(step.nextDirection, equals(expectedDirection));
      },
    );

    test('should_be_equal_when_fields_match', () {
      // Arrange
      const first = PathStep(
        outcome: PathOutcome.exitReached,
        nextDirection: Direction.up,
      );
      const second = PathStep(
        outcome: PathOutcome.exitReached,
        nextDirection: Direction.up,
      );

      // Act & Assert
      expect(first, equals(second));
    });

    test('should_be_not_equal_when_outcome_differs', () {
      // Arrange
      const first = PathStep(
        outcome: PathOutcome.continuePath,
        nextDirection: Direction.down,
      );
      const second = PathStep(
        outcome: PathOutcome.blocked,
        nextDirection: Direction.down,
      );

      // Act & Assert
      expect(first, isNot(equals(second)));
    });

    test('should_be_not_equal_when_direction_differs', () {
      // Arrange
      const first = PathStep(
        outcome: PathOutcome.continuePath,
        nextDirection: Direction.left,
      );
      const second = PathStep(
        outcome: PathOutcome.continuePath,
        nextDirection: Direction.right,
      );

      // Act & Assert
      expect(first, isNot(equals(second)));
    });
  });

  group('Board.isPathClear', () {
    test(
      'should_return_true_when_arrow_reaches_exit_cell',
      () {
        // Arrange
        // 3x3 grid:
        // (0,0) Arrow right -> (0,1) Empty -> (0,2) Exit
        final arrow = ArrowCell(
          id: 'arrow_0_0',
          position: const Position(x: 0, y: 0),
          direction: Direction.right,
        );
        final empty = EmptyCell(
          id: 'empty_0_1',
          position: const Position(x: 0, y: 1),
        );
        final exit = ExitCell(
          id: 'exit_0_2',
          position: const Position(x: 0, y: 2),
        );
        final board = Board.fromComponents(
          components: [arrow, empty, exit],
          rows: 3,
          cols: 3,
        );

        // Act
        final isClear = board.isPathClear(const Position(x: 0, y: 0));

        // Assert
        expect(isClear, isTrue);
      },
    );

    test('should_return_false_when_arrow_hits_wall_cell', () {
      // Arrange
      // 3x3 grid:
      // (0,0) Arrow right -> (0,1) Wall
      final arrow = ArrowCell(
        id: 'arrow_0_0',
        position: const Position(x: 0, y: 0),
        direction: Direction.right,
      );
      final wall = WallCell(
        id: 'wall_0_1',
        position: const Position(x: 0, y: 1),
      );
      final board = Board.fromComponents(
        components: [arrow, wall],
        rows: 3,
        cols: 3,
      );

      // Act
      final isClear = board.isPathClear(const Position(x: 0, y: 0));

      // Assert
      expect(isClear, isFalse);
    });

    test(
      'should_return_false_when_path_contains_cycle',
      () {
        // Arrange
        // 3x3 grid:
        // (0,0) Arrow right <-> (0,1) Arrow left
        final arrowLeft = ArrowCell(
          id: 'arrow_0_0',
          position: const Position(x: 0, y: 0),
          direction: Direction.right,
        );
        final arrowRight = ArrowCell(
          id: 'arrow_0_1',
          position: const Position(x: 0, y: 1),
          direction: Direction.left,
        );
        final board = Board.fromComponents(
          components: [arrowLeft, arrowRight],
          rows: 3,
          cols: 3,
        );

        // Act
        final isClear = board.isPathClear(const Position(x: 0, y: 0));

        // Assert
        expect(isClear, isFalse);
      },
    );

    test(
      'should_return_false_when_path_goes_out_of_bounds',
      () {
        // Arrange
        // 3x3 grid:
        // (0,0) Arrow up -> outside the board
        final arrow = ArrowCell(
          id: 'arrow_0_0',
          position: const Position(x: 0, y: 0),
          direction: Direction.up,
        );
        final board = Board.fromComponents(
          components: [arrow],
          rows: 3,
          cols: 3,
        );

        // Act
        final isClear = board.isPathClear(const Position(x: 0, y: 0));

        // Assert
        expect(isClear, isFalse);
      },
    );

    test(
      'should_return_true_when_starting_from_empty_cell_reaches_exit',
      () {
        // Arrange
        // 3x3 grid:
        // (0,0) Exit <- (1,0) Empty <- (2,0) Empty (start)
        // Default direction for a non-arrow start is [Direction.up].
        final exit = ExitCell(
          id: 'exit_0_0',
          position: const Position(x: 0, y: 0),
        );
        final emptyMiddle = EmptyCell(
          id: 'empty_1_0',
          position: const Position(x: 1, y: 0),
        );
        final emptyStart = EmptyCell(
          id: 'empty_2_0',
          position: const Position(x: 2, y: 0),
        );
        final board = Board.fromComponents(
          components: [exit, emptyMiddle, emptyStart],
          rows: 3,
          cols: 3,
        );

        // Act
        final isClear = board.isPathClear(const Position(x: 2, y: 0));

        // Assert
        expect(isClear, isTrue);
      },
    );

    test(
      'should_return_false_when_starting_from_empty_position',
      () {
        // Arrange
        final board = Board.fromComponents(
          components: const [],
          rows: 3,
          cols: 3,
        );

        // Act
        final isClear = board.isPathClear(const Position(x: 1, y: 1));

        // Assert
        expect(isClear, isFalse);
      },
    );
  });

  group('Board.cellResolver', () {
    test('should_return_cell_when_position_is_valid', () {
      // Arrange
      final arrow = ArrowCell(
        id: 'arrow_1_1',
        position: const Position(x: 1, y: 1),
        direction: Direction.up,
      );
      final empty = EmptyCell(
        id: 'empty_2_2',
        position: const Position(x: 2, y: 2),
      );
      final board = Board.fromComponents(
        components: [arrow, empty],
        rows: 3,
        cols: 3,
      );
      final CellResolver resolver = board.cellResolver;

      // Act
      final resolvedArrow = resolver(const Position(x: 1, y: 1));
      final resolvedEmpty = resolver(const Position(x: 2, y: 2));

      // Assert
      expect(resolvedArrow, equals(arrow));
      expect(resolvedEmpty, equals(empty));
    });

    test('should_return_null_when_position_is_out_of_bounds', () {
      // Arrange
      final arrow = ArrowCell(
        id: 'arrow_0_0',
        position: const Position(x: 0, y: 0),
        direction: Direction.right,
      );
      final board = Board.fromComponents(
        components: [arrow],
        rows: 3,
        cols: 3,
      );
      final CellResolver resolver = board.cellResolver;

      // Act
      final outOfBoundsCell = resolver(const Position(x: 5, y: 5));

      // Assert
      expect(outOfBoundsCell, isNull);
    });
  });
}
