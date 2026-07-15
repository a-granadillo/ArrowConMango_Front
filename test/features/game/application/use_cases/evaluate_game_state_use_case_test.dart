import 'package:arrowconmango_front/features/game/application/dtos/game_evaluation.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/evaluate_game_state_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/entities/score.dart';
import 'package:arrowconmango_front/features/game/domain/entities/scoring_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

/// Manual fake for [BoardState] that reports a fixed [arrowCount].
class FakeBoardState extends BoardState {
  final int arrowCountValue;

  FakeBoardState({required this.arrowCountValue}) : super(arrows: const []);

  @override
  int get arrowCount => arrowCountValue;
}

/// Manual fake for [GameSession] that controls the values used by
/// [EvaluateGameStateUseCase].
class FakeGameSession extends GameSession {
  final bool isVictoryValue;
  final int elapsedSecondsValue;
  final int moveCountValue;

  FakeGameSession({
    required super.sessionId,
    required super.boardState,
    required super.startedAtMs,
    required this.moveCountValue,
    required this.isVictoryValue,
    required this.elapsedSecondsValue,
  });

  @override
  bool get isVictory => isVictoryValue;

  @override
  int get moveCount => moveCountValue;

  @override
  int elapsedSeconds(int nowMs) => elapsedSecondsValue;
}

/// Manual mock for [ScoringStrategy].
class MockScoringStrategy implements ScoringStrategy {
  Score _score = const Score();

  void setScore(Score score) {
    _score = score;
  }

  @override
  Score calculateScore(int moves, int seconds) => _score;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('EvaluateGameStateUseCase', () {
    const testSessionId = 'test-session-id';
    const testStartedAtMs = 1_700_000_000_000;
    const testNowMs = 1_700_000_045_000;

    late MockScoringStrategy mockScoringStrategy;
    late EvaluateGameStateUseCase useCase;

    setUp(() {
      mockScoringStrategy = MockScoringStrategy();
      useCase = EvaluateGameStateUseCase(mockScoringStrategy);
    });

    test(
      'should_return_ongoing_evaluation_when_game_is_not_won',
      () {
        // Arrange
        const expectedScore = Score(
          moves: 3,
          timeElapsed: 45,
          totalPoints: 100,
        );
        mockScoringStrategy.setScore(expectedScore);

        final session = FakeGameSession(
          sessionId: testSessionId,
          boardState: FakeBoardState(arrowCountValue: 2),
          startedAtMs: testStartedAtMs,
          moveCountValue: 3,
          isVictoryValue: false,
          elapsedSecondsValue: 45,
        );

        // Act
        final result = useCase(session: session, nowMs: testNowMs);

        // Assert
        expect(
          result,
          equals(
            const GameEvaluation(
              status: GameStatus.ongoing,
              score: expectedScore,
              moveCount: 3,
              elapsedSeconds: 45,
              arrowsRemaining: 2,
            ),
          ),
        );
      },
    );

    test(
      'should_return_victory_evaluation_when_game_is_won',
      () {
        // Arrange
        const expectedScore = Score(
          moves: 5,
          timeElapsed: 100,
          totalPoints: 500,
        );
        mockScoringStrategy.setScore(expectedScore);

        final session = FakeGameSession(
          sessionId: testSessionId,
          boardState: FakeBoardState(arrowCountValue: 0),
          startedAtMs: testStartedAtMs,
          moveCountValue: 5,
          isVictoryValue: true,
          elapsedSecondsValue: 100,
        );

        // Act
        final result = useCase(session: session, nowMs: testNowMs);

        // Assert
        expect(
          result,
          equals(
            const GameEvaluation(
              status: GameStatus.victory,
              score: expectedScore,
              moveCount: 5,
              elapsedSeconds: 100,
              arrowsRemaining: 0,
            ),
          ),
        );
      },
    );
  });
}