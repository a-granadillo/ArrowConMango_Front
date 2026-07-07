import 'package:arrowconmango_front/features/game/application/use_cases/load_progress_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_progress_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:flutter_test/flutter_test.dart';

/// Manual fake for [IProgressRepository].
///
/// Allows tests to configure the result returned by [loadProgress] or to
/// simulate an unhandled exception. [saveProgress] is not exercised by
/// [LoadProgressUseCase] and therefore throws [UnimplementedError].
class FakeProgressRepository implements IProgressRepository {
  Result<AppProgress>? loadResult;
  Object? exceptionToThrow;

  @override
  Future<Result<AppProgress>> loadProgress() async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }

    return loadResult!;
  }

  @override
  Future<Result<void>> saveProgress(AppProgress progress) async {
    throw UnimplementedError('saveProgress() should not be called');
  }
}

void main() {
  group('LoadProgressUseCase', () {
    late FakeProgressRepository fakeRepository;
    late LoadProgressUseCase useCase;

    setUp(() {
      fakeRepository = FakeProgressRepository();
      useCase = LoadProgressUseCase(fakeRepository);
    });

    test(
      'should_return_progress_when_repository_loads_successfully',
      () async {
        // Arrange
        const progress = AppProgress(
          unlockedLevels: [1, 2, 3],
          currentToken: 'session-token',
        );
        fakeRepository.loadResult = const Success<AppProgress>(progress);

        // Act
        final result = await useCase();

        // Assert
        expect(result, isA<Success<AppProgress>>());
        expect((result as Success<AppProgress>).value, equals(progress));
      },
    );

    test(
      'should_return_error_when_repository_returns_a_failure',
      () async {
        // Arrange
        const failure = GenericFailure('Storage read failed');
        fakeRepository.loadResult = const Error<AppProgress>(failure);

        // Act
        final result = await useCase();

        // Assert
        expect(result, isA<Error<AppProgress>>());
        expect((result as Error<AppProgress>).failure, equals(failure));
      },
    );

    test(
      'should_return_generic_failure_when_repository_throws_unhandled_exception',
      () async {
        // Arrange
        fakeRepository.exceptionToThrow = Exception('Unexpected load error');

        // Act
        final result = await useCase();

        // Assert
        expect(result, isA<Error<AppProgress>>());
        final failure = (result as Error<AppProgress>).failure;
        expect(failure, isA<GenericFailure>());
        expect(failure.message, contains('Unexpected load error'));
      },
    );
  });
}
