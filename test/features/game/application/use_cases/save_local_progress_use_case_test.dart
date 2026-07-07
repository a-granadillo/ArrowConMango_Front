import 'package:arrowconmango_front/features/game/application/use_cases/save_local_progress_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes/fake_progress_repository.dart';

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
        switch (result) {
          case Success<void>():
            expect(fakeRepository.savedProgress, equals(progress));
          case Error(:final failure):
            fail('Expected Success, got Error: $failure');
        }
      },
    );

    test(
      'should_return_error_when_repository_returns_a_failure',
      () async {
        // Arrange
        const expectedFailure = GenericFailure('Failed to write progress');
        fakeRepository.saveResult = const Error<void>(expectedFailure);
        const progress = AppProgress(
          unlockedLevels: [3],
          currentToken: 'another-token',
        );

        // Act
        final result = await useCase(progress: progress);

        // Assert
        switch (result) {
          case Success<void>():
            fail('Expected Error, got Success');
          case Error(:final failure):
            expect(failure, equals(expectedFailure));
        }
        expect(fakeRepository.savedProgress, equals(progress));
      },
    );

    test(
      'should_return_generic_failure_when_repository_throws_unhandled_exception',
      () async {
        // Arrange
        fakeRepository.saveExceptionToThrow = Exception('Unexpected storage error');
        const progress = AppProgress();

        // Act
        final result = await useCase(progress: progress);

        // Assert
        switch (result) {
          case Success<void>():
            fail('Expected Error, got Success');
          case Error(:final failure):
            expect(failure, isA<GenericFailure>());
            expect(failure.message, contains('Unexpected storage error'));
        }
      },
    );
  });
}
