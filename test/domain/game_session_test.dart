import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/entities/node_id.dart';
import 'package:arrowconmango_front/features/game/domain/errors/arrow_not_found_failure.dart';
import 'package:test/test.dart';

void main() {
  group('GameSession', () {
    late GameSession session;
    late ArrowEntity arrow1;
    late ArrowEntity arrow2;
    late ArrowEntity nonExistentArrow;

    setUp(() {
      final node1 = Grid2DNodeId(row: 0, col: 0);
      final node2 = Grid2DNodeId(row: 1, col: 0);

      arrow1 = ArrowEntity(
        id: 'arrow1',
        direction: CardinalDirection.right,
        occupiedNodes: [node1],
      );

      arrow2 = ArrowEntity(
        id: 'arrow2',
        direction: CardinalDirection.down,
        occupiedNodes: [node2],
      );

      nonExistentArrow = ArrowEntity(
        id: 'nonexistent',
        direction: CardinalDirection.up,
        occupiedNodes: [Grid2DNodeId(row: 2, col: 2)],
      );

      final board = BoardState(arrows: [arrow1, arrow2]);
      session = GameSession(
        sessionId: 'test-session',
        boardState: board,
        startedAtMs: 1000,
      );
    });

    group('afterArrowExit', () {
      test('should_remove_arrow_from_board_when_valid', () {
        // Act
        final updated = session.afterArrowExit(arrow1);

        // Assert
        expect(updated.boardState.arrowCount, 1);
        expect(updated.boardState.getArrowById('arrow1'), isNull);
        expect(updated.boardState.getArrowById('arrow2'), isNotNull);
      });

      test('should_increment_move_count', () {
        // Act
        final updated = session.afterArrowExit(arrow1);

        // Assert
        expect(updated.moveCount, 1);
      });

      test('should_throw_ArrowNotFoundFailure_when_arrow_not_in_board', () {
        // Act & Assert
        expect(
          () => session.afterArrowExit(nonExistentArrow),
          throwsA(isA<ArrowNotFoundFailure>()),
        );
      });

      test('should_throw_ArrowNotFoundFailure_when_arrow_already_exited', () {
        // Arrange
        final updated = session.afterArrowExit(arrow1);

        // Act & Assert
        expect(
          () => updated.afterArrowExit(arrow1),
          throwsA(isA<ArrowNotFoundFailure>()),
        );
      });
    });

    group('undoLastMove', () {
      test('should_restore_previous_board_state', () {
        // Arrange
        final afterExit = session.afterArrowExit(arrow1);

        // Act
        final restored = afterExit.undoLastMove();

        // Assert
        expect(restored.boardState.arrowCount, 2);
        expect(restored.boardState.getArrowById('arrow1'), isNotNull);
      });

      test('should_decrement_move_count', () {
        // Arrange
        final afterExit = session.afterArrowExit(arrow1);

        // Act
        final restored = afterExit.undoLastMove();

        // Assert
        expect(restored.moveCount, 0);
      });

      test('should_return_same_session_when_no_moves', () {
        // Act
        final result = session.undoLastMove();

        // Assert
        expect(identical(result, session), isTrue);
      });
    });
  });
}
