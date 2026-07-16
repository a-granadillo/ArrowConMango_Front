import 'package:arrowconmango_front/features/game/application/use_cases/calculate_score_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/score.dart';
import 'package:arrowconmango_front/features/game/domain/entities/scoring_strategy.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:flutter_test/flutter_test.dart';

/// Manual fake for [ScoringStrategy].
///
/// Allows tests to configure the [Score] returned by [calculateScore] or
/// to simulate an exception thrown by the strategy.
class FakeScoringStrategy implements ScoringStrategy {
  Score? scoreToReturn;
  Object? exceptionToThrow;

  @override
  Score calculateScore(int moves, int seconds, {int mistakes = 0}) {
    final exception = exceptionToThrow;
    if (exception != null) {
      throw exception;
    }

    final result = scoreToReturn;
    if (result == null) {
      throw StateError(
        'Debes configurar scoreToReturn en el Arrange del test',
      );
    }
    return result;
  }
}

void main() {
  group('CalculateScoreUseCase', () {
    late FakeScoringStrategy fakeStrategy;
    late CalculateScoreUseCase useCase;

    setUp(() {
      fakeStrategy = FakeScoringStrategy();
      useCase = CalculateScoreUseCase(fakeStrategy);
    });

    test(
      'should_return_score_when_strategy_calculates_successfully',
      () {
        // Arrange
        const expectedScore = Score(
          moves: 10,
          timeElapsed: 30,
          totalPoints: 2500,
        );
        fakeStrategy.scoreToReturn = expectedScore;

        // Act
        final result = useCase(moves: 10, elapsedSeconds: 30);

        // Assert
        switch (result) {
          case Success(:final value):
            expect(value, equals(expectedScore));
          case Error(:final failure):
            fail('Expected Success, got Error: $failure');
        }
      },
    );

    test(
      'should_return_error_when_moves_is_negative',
      () {
        // Arrange
        const moves = -1;
        const elapsedSeconds = 30;

        // Act
        final result = useCase(moves: moves, elapsedSeconds: elapsedSeconds);

        // Assert
        switch (result) {
          case Success(:final value):
            fail('Expected Error, got Success: $value');
          case Error(:final failure):
            expect(failure, isA<GenericFailure>());
        }
      },
    );

    test(
      'should_return_error_when_elapsed_seconds_is_negative',
      () {
        // Arrange
        const moves = 10;
        const elapsedSeconds = -5;

        // Act
        final result = useCase(moves: moves, elapsedSeconds: elapsedSeconds);

        // Assert
        switch (result) {
          case Success(:final value):
            fail('Expected Error, got Success: $value');
          case Error(:final failure):
            expect(failure, isA<GenericFailure>());
        }
      },
    );

    test(
      'should_return_error_when_both_params_are_negative',
      () {
        // Arrange
        const moves = -3;
        const elapsedSeconds = -7;

        // Act
        final result = useCase(moves: moves, elapsedSeconds: elapsedSeconds);

        // Assert
        switch (result) {
          case Success(:final value):
            fail('Expected Error, got Success: $value');
          case Error(:final failure):
            expect(failure, isA<GenericFailure>());
        }
      },
    );

    test(
      'should_return_generic_failure_when_strategy_throws_exception',
      () {
        // Arrange
        fakeStrategy.exceptionToThrow = Exception('Unexpected scoring error');

        // Act
        final result = useCase(moves: 5, elapsedSeconds: 15);

        // Assert
        switch (result) {
          case Success(:final value):
            fail('Expected Error, got Success: $value');
          case Error(:final failure):
            expect(failure, isA<GenericFailure>());
            expect(failure.message, contains('Unexpected scoring error'));
        }
      },
    );
  });
}
