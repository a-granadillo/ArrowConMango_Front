import 'package:arrowconmango_front/features/game/application/use_cases/trigger_arrow_exit_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/exit_check_result.dart';
import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/entities/node_id.dart';
import 'package:arrowconmango_front/features/game/domain/errors/arrow_not_found_failure.dart';
import 'package:arrowconmango_front/features/game/domain/errors/path_blocked_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/game/domain/services/collision_validator.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

class _FakeNodeId extends NodeId {
  @override
  final String key;

  const _FakeNodeId(this.key);
}

class _FakeDirection implements Direction {
  const _FakeDirection();

  @override
  String get label => 'right';
}

/// Manual fake that controls which [ArrowEntity] is found on the board.
class _FakeBoardState extends BoardState {
  final ArrowEntity? _arrowToReturn;

  _FakeBoardState({ArrowEntity? arrowToReturn})
    : _arrowToReturn = arrowToReturn,
      super(arrows: const []);

  @override
  ArrowEntity? getArrowById(String id) => _arrowToReturn;
}

/// Manual fake that controls the result of [afterArrowExit].
class _FakeGameSession extends GameSession {
  final GameSession? _nextSession;
  final Exception? _exceptionToThrow;

  _FakeGameSession({
    required super.sessionId,
    required super.boardState,
    required super.startedAtMs,
    GameSession? nextSession,
    Exception? exceptionToThrow,
  }) : assert(
         nextSession == null || exceptionToThrow == null,
         'Provide either nextSession or exceptionToThrow, not both.',
       ),
       _nextSession = nextSession,
       _exceptionToThrow = exceptionToThrow;

  @override
  GameSession afterArrowExit(ArrowEntity arrow) {
    if (_exceptionToThrow != null) {
      throw _exceptionToThrow!;
    }
    return _nextSession!;
  }
}

/// Manual mock for [CollisionValidator].
class MockCollisionValidator implements CollisionValidator {
  ExitCheckResult _result = const ExitCheckResult(
    canExit: true,
    blockingArrowId: null,
    clearPath: [],
  );

  void setExitResult(ExitCheckResult result) {
    _result = result;
  }

  @override
  ExitCheckResult checkExit(ArrowEntity arrow, BoardState board) => _result;

  @override
  bool canSlide(ArrowEntity arrow, BoardState board, int steps) {
    throw UnimplementedError('canSlide() should not be called');
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TriggerArrowExitUseCase', () {
    const testSessionId = 'test-session-id';
    const testStartedAtMs = 1_700_000_000_000;
    const testArrowId = 'arrow-1';
    const testBlockingArrowId = 'arrow-2';

    late MockCollisionValidator mockValidator;
    late TriggerArrowExitUseCase useCase;
    late ArrowEntity testArrow;

    setUp(() {
      mockValidator = MockCollisionValidator();
      useCase = TriggerArrowExitUseCase(mockValidator);
      testArrow = const ArrowEntity(
        id: testArrowId,
        direction: _FakeDirection(),
        occupiedNodes: [_FakeNodeId('n1')],
      );
    });

    test(
      'should_return_error_when_arrow_not_found',
      () {
        // Arrange
        final session = _FakeGameSession(
          sessionId: testSessionId,
          boardState: _FakeBoardState(arrowToReturn: null),
          startedAtMs: testStartedAtMs,
        );

        // Act
        final result = useCase(session: session, arrowId: testArrowId);

        // Assert
        expect(result, isA<Error<GameSession>>());
        final failure = (result as Error<GameSession>).failure;
        expect(failure, isA<ArrowNotFoundFailure>());
        expect((failure as ArrowNotFoundFailure).arrowId, testArrowId);
      },
    );

    test(
      'should_return_error_when_path_blocked',
      () {
        // Arrange
        final session = _FakeGameSession(
          sessionId: testSessionId,
          boardState: _FakeBoardState(arrowToReturn: testArrow),
          startedAtMs: testStartedAtMs,
        );
        mockValidator.setExitResult(
          const ExitCheckResult(
            canExit: false,
            blockingArrowId: testBlockingArrowId,
            clearPath: [],
          ),
        );

        // Act
        final result = useCase(session: session, arrowId: testArrowId);

        // Assert
        expect(result, isA<Error<GameSession>>());
        final failure = (result as Error<GameSession>).failure;
        expect(failure, isA<PathBlockedFailure>());
        expect(
          (failure as PathBlockedFailure).movingArrowId,
          testArrowId,
        );
        expect(failure.blockingArrowId, testBlockingArrowId);
      },
    );

    test(
      'should_return_success_when_arrow_can_exit',
      () {
        // Arrange
        final expectedSession = GameSession(
          sessionId: testSessionId,
          boardState: BoardState(arrows: const []),
          startedAtMs: testStartedAtMs,
        );
        final session = _FakeGameSession(
          sessionId: testSessionId,
          boardState: _FakeBoardState(arrowToReturn: testArrow),
          startedAtMs: testStartedAtMs,
          nextSession: expectedSession,
        );
        mockValidator.setExitResult(
          const ExitCheckResult(
            canExit: true,
            blockingArrowId: null,
            clearPath: [],
          ),
        );

        // Act
        final result = useCase(session: session, arrowId: testArrowId);

        // Assert
        expect(result, isA<Success<GameSession>>());
        expect((result as Success<GameSession>).value, equals(expectedSession));
      },
    );

    test(
      'should_return_error_when_unexpected_exception_in_afterArrowExit',
      () {
        // Arrange
        final session = _FakeGameSession(
          sessionId: testSessionId,
          boardState: _FakeBoardState(arrowToReturn: testArrow),
          startedAtMs: testStartedAtMs,
          exceptionToThrow: FormatException('unexpected failure'),
        );
        mockValidator.setExitResult(
          const ExitCheckResult(
            canExit: true,
            blockingArrowId: null,
            clearPath: [],
          ),
        );

        // Act
        final result = useCase(session: session, arrowId: testArrowId);

        // Assert
        expect(result, isA<Error<GameSession>>());
        final failure = (result as Error<GameSession>).failure;
        expect(failure.message, contains('unexpected failure'));
      },
    );
  });
}
