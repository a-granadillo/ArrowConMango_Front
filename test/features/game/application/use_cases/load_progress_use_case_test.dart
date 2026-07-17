import 'package:arrowconmango_front/features/game/application/use_cases/load_progress_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes/fake_progress_repository.dart';

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
          currentLevel: 3,
        );
        fakeRepository.loadResult = const Success<AppProgress>(progress);

        // Act
        final result = await useCase();

        // Assert
        switch (result) {
          case Success(:final value):
            expect(value, equals(progress));
          case Error(:final failure):
            fail('Expected Success, got Error: $failure');
        }
      },
    );

    test(
      'should_return_error_when_repository_returns_a_failure',
      () async {
        // Arrange
        const expectedFailure = GenericFailure('Storage read failed');
        fakeRepository.loadResult = const Error<AppProgress>(expectedFailure);

        // Act
        final result = await useCase();

        // Assert
        switch (result) {
          case Success(:final value):
            fail('Expected Error, got Success: $value');
          case Error(:final failure):
            expect(failure, equals(expectedFailure));
        }
      },
    );

    test(
      'should_return_generic_failure_when_repository_throws_unhandled_exception',
      () async {
        // Arrange
        fakeRepository.loadExceptionToThrow = Exception('Unexpected load error');

        // Act
        final result = await useCase();

        // Assert
        switch (result) {
          case Success(:final value):
            fail('Expected Error, got Success: $value');
          case Error(:final failure):
            expect(failure, isA<GenericFailure>());
            expect(failure.message, contains('Unexpected load error'));
        }
      },
    );
  });
}
