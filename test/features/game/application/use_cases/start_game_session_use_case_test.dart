import 'package:arrowconmango_front/features/game/application/use_cases/start_game_session_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:flutter_test/flutter_test.dart';

/// Manual fake for [Level] used to control the behaviour of [startSession].
///
/// Configure it with either a [GameSession] to return or an [Exception] to
/// throw, which allows the [StartGameSessionUseCase] try/catch path to be
/// exercised without relying on real level logic.
class FakeLevel extends Level {
  final GameSession? _sessionToReturn;
  final Exception? _exceptionToThrow;

  FakeLevel({GameSession? sessionToReturn, Exception? exceptionToThrow})
    : assert(
        (sessionToReturn != null) != (exceptionToThrow != null),
        'Provide either a session to return or an exception to throw, not both.',
      ),
      _sessionToReturn = sessionToReturn,
      _exceptionToThrow = exceptionToThrow,
      super(
        levelId: 1,
        templateBoard: BoardState(arrows: const []),
      );

  @override
  GameSession startSession({
    required String sessionId,
    required int startedAtMs,
  }) {
    if (_exceptionToThrow != null) {
      throw _exceptionToThrow;
    }
    return _sessionToReturn!;
  }
}

void main() {
  group('StartGameSessionUseCase', () {
    const testSessionId = 'test-session-id';
    const testStartedAtMs = 1_700_000_000_000;

    late StartGameSessionUseCase useCase;

    setUp(() {
      useCase = const StartGameSessionUseCase();
    });

    test(
      'should_return_success_when_level_starts_session',
      () {
        // Arrange
        final expectedSession = GameSession(
          sessionId: testSessionId,
          boardState: BoardState(arrows: const []),
          startedAtMs: testStartedAtMs,
        );
        final fakeLevel = FakeLevel(sessionToReturn: expectedSession);

        // Act
        final result = useCase(
          level: fakeLevel,
          sessionId: testSessionId,
          startedAtMs: testStartedAtMs,
        );

        // Assert
        expect(result, isA<Success<GameSession>>());
        expect((result as Success<GameSession>).value, equals(expectedSession));
      },
    );

    test(
      'should_return_error_when_level_throws_exception',
      () {
        // Arrange
        final fakeLevel = FakeLevel(
          exceptionToThrow: Exception('session start failed'),
        );

        // Act
        final result = useCase(
          level: fakeLevel,
          sessionId: testSessionId,
          startedAtMs: testStartedAtMs,
        );

        // Assert
        expect(result, isA<Error<GameSession>>());
        final failure = (result as Error<GameSession>).failure;
        expect(failure.message, contains('Failed to start session:'));
        expect(failure.message, contains('session start failed'));
      },
    );
  });
}
