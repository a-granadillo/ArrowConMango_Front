import 'package:arrowconmango_front/features/game/application/use_cases/undo_move_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/command_history.dart';
import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

/// Manual fake for [CommandHistory] that reports a fixed [canUndo] value.
class FakeCommandHistory extends CommandHistory {
  final bool canUndoValue;

  const FakeCommandHistory({required this.canUndoValue}) : super();

  @override
  bool get canUndo => canUndoValue;
}

/// Manual fake for [GameSession] that controls [history.canUndo] and
/// the result of [undoLastMove].
class FakeGameSession extends GameSession {
  final GameSession? sessionAfterUndoMock;

  FakeGameSession({
    required super.sessionId,
    required super.boardState,
    required super.startedAtMs,
    required super.history,
    this.sessionAfterUndoMock,
  });

  @override
  GameSession undoLastMove() {
    final next = sessionAfterUndoMock;
    if (next == null) {
      throw StateError('undoLastMove() called but no sessionAfterUndo was configured');
    }
    return next;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('UndoMoveUseCase', () {
    const testSessionId = 'test-session-id';
    const testStartedAtMs = 1_700_000_000_000;

    late UndoMoveUseCase useCase;

    setUp(() {
      useCase = const UndoMoveUseCase();
    });

    test(
      'should_return_error_when_no_moves_to_undo',
      () {
        // Arrange
        final session = FakeGameSession(
          sessionId: testSessionId,
          boardState: BoardState(arrows: const []),
          startedAtMs: testStartedAtMs,
          history: const FakeCommandHistory(canUndoValue: false),
        );

        // Act
        final result = useCase(session: session);

        // Assert
        expect(result, isA<Error<GameSession>>());
        expect((result as Error<GameSession>).failure.message, 'No moves to undo');
      },
    );

    test(
      'should_return_success_when_undo_is_available',
      () {
        // Arrange
        final expectedSession = GameSession(
          sessionId: testSessionId,
          boardState: BoardState(arrows: const []),
          startedAtMs: testStartedAtMs,
        );
        final session = FakeGameSession(
          sessionId: testSessionId,
          boardState: BoardState(arrows: const []),
          startedAtMs: testStartedAtMs,
          history: const FakeCommandHistory(canUndoValue: true),
          sessionAfterUndoMock: expectedSession,
        );

        // Act
        final result = useCase(session: session);

        // Assert
        expect(result, isA<Success<GameSession>>());
        expect((result as Success<GameSession>).value, equals(expectedSession));
      },
    );
  });
}