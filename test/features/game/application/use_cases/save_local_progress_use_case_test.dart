import 'package:arrowconmango_front/features/game/application/use_cases/save_local_progress_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_progress_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:flutter_test/flutter_test.dart';

/// Manual fake for [IProgressRepository].
///
/// Allows tests to configure the result returned by [saveProgress] or to
/// simulate an unhandled exception. The progress entity passed to
/// [saveProgress] is captured so tests can verify the use case forwards
/// the correct value.
class FakeProgressRepository implements IProgressRepository {
  Result<void>? saveResult;
  Object? exceptionToThrow;
  AppProgress? savedProgress;

  @override
  Future<Result<AppProgress>> loadProgress() async {
    throw UnimplementedError('loadProgress() should not be called');
  }

  @override
  Future<Result<void>> saveProgress(AppProgress progress) async {
    savedProgress = progress;

    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }

    return saveResult!;
  }
}

void main() {
  group('SaveLocalProgressUseCase', () {
    late FakeProgressRepository fakeRepository;
    late SaveLocalProgressUseCase useCase;

    setUp(() {
      fakeRepository = FakeProgressRepository();
      useCase = SaveLocalProgressUseCase(fakeRepository);
    });

    test(
      'should_return_success_when_repository_saves_progress',
      () async {
        // Arrange
        fakeRepository.saveResult = const Success<void>(null);
        const progress = AppProgress(
          unlockedLevels: [1, 2],
          currentToken: 'session-token',
        );

        // Act
        final result = await useCase(progress: progress);

        // Assert
        expect(result, isA<Success<void>>());
        expect(fakeRepository.savedProgress, equals(progress));
      },
    );

    test(
      'should_return_error_when_repository_returns_a_failure',
      () async {
        // Arrange
        const failure = GenericFailure('Failed to write progress');
        fakeRepository.saveResult = const Error<void>(failure);
        const progress = AppProgress(
          unlockedLevels: [3],
          currentToken: 'another-token',
        );

        // Act
        final result = await useCase(progress: progress);

        // Assert
        expect(result, isA<Error<void>>());
        expect((result as Error<void>).failure, equals(failure));
        expect(fakeRepository.savedProgress, equals(progress));
      },
    );

    test(
      'should_return_generic_failure_when_repository_throws_unhandled_exception',
      () async {
        // Arrange
        fakeRepository.exceptionToThrow = Exception('Unexpected storage error');
        const progress = AppProgress();

        // Act
        final result = await useCase(progress: progress);

        // Assert
        expect(result, isA<Error<void>>());
        final failure = (result as Error<void>).failure;
        expect(failure, isA<GenericFailure>());
        expect(failure.message, contains('Unexpected storage error'));
      },
    );
  });
}
