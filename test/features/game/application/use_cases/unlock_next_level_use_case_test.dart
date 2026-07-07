import 'package:arrowconmango_front/features/game/application/use_cases/unlock_next_level_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/errors/level_not_found_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes/fake_level_repository.dart';
import '../../../../helpers/fakes/fake_progress_repository.dart';

void main() {
  group('UnlockNextLevelUseCase', () {
    late FakeProgressRepository fakeProgressRepository;
    late FakeLevelRepository fakeLevelRepository;
    late UnlockNextLevelUseCase useCase;

    setUp(() {
      fakeProgressRepository = FakeProgressRepository();
      fakeLevelRepository = FakeLevelRepository();
      useCase = UnlockNextLevelUseCase(
        fakeProgressRepository,
        fakeLevelRepository,
      );
    });

    test(
      'should_return_updated_progress_when_unlocking_next_level_succeeds',
      () async {
        // Arrange
        fakeLevelRepository.countResult = const Success<int>(5);
        fakeProgressRepository.loadResult = const Success<AppProgress>(
          AppProgress(unlockedLevels: [1]),
        );
        fakeProgressRepository.saveResult = const Success<void>(null);

        // Act
        final result = await useCase(currentLevelId: 1);

        // Assert
        switch (result) {
          case Success(:final value):
            expect(value, equals(const AppProgress(unlockedLevels: [1, 2])));
          case Error(:final failure):
            fail('Expected Success, got Error: $failure');
        }
        expect(
          fakeProgressRepository.savedProgress,
          equals(const AppProgress(unlockedLevels: [1, 2])),
        );
      },
    );

    test(
      'should_succeed_when_next_level_already_unlocked',
      () async {
        // Arrange
        fakeLevelRepository.countResult = const Success<int>(3);
        fakeProgressRepository.loadResult = const Success<AppProgress>(
          AppProgress(unlockedLevels: [1, 2]),
        );
        fakeProgressRepository.saveResult = const Success<void>(null);

        // Act
        final result = await useCase(currentLevelId: 1);

        // Assert
        switch (result) {
          case Success(:final value):
            expect(value, equals(const AppProgress(unlockedLevels: [1, 2])));
          case Error(:final failure):
            fail('Expected Success, got Error: $failure');
        }
        expect(
          fakeProgressRepository.savedProgress,
          equals(const AppProgress(unlockedLevels: [1, 2])),
        );
      },
    );

    test(
      'should_return_level_not_found_failure_when_next_level_exceeds_total',
      () async {
        // Arrange
        fakeLevelRepository.countResult = const Success<int>(3);
        fakeProgressRepository.loadResult = const Success<AppProgress>(
          AppProgress(unlockedLevels: [1, 2, 3]),
        );

        // Act
        final result = await useCase(currentLevelId: 3);

        // Assert
        switch (result) {
          case Success(:final value):
            fail('Expected Error, got Success: $value');
          case Error(:final failure):
            expect(failure, isA<LevelNotFoundFailure>());
            expect(
              failure,
              equals(const LevelNotFoundFailure(levelId: 4)),
            );
        }
        expect(fakeProgressRepository.savedProgress, isNull);
      },
    );

    test(
      'should_return_generic_failure_when_current_level_id_is_invalid',
      () async {
        // Arrange
        const invalidLevelId = 0;

        // Act
        final result = await useCase(currentLevelId: invalidLevelId);

        // Assert
        switch (result) {
          case Success(:final value):
            fail('Expected Error, got Success: $value');
          case Error(:final failure):
            expect(failure, isA<GenericFailure>());
        }
        expect(fakeProgressRepository.savedProgress, isNull);
      },
    );

    test(
      'should_return_generic_failure_when_load_progress_fails',
      () async {
        // Arrange
        fakeProgressRepository.loadResult = const Error<AppProgress>(
          GenericFailure('Progress unavailable'),
        );

        // Act
        final result = await useCase(currentLevelId: 1);

        // Assert
        switch (result) {
          case Success(:final value):
            fail('Expected Error, got Success: $value');
          case Error(:final failure):
            expect(failure, isA<GenericFailure>());
        }
        expect(fakeProgressRepository.savedProgress, isNull);
      },
    );

    test(
      'should_return_generic_failure_when_get_level_count_fails',
      () async {
        // Arrange
        fakeProgressRepository.loadResult = const Success<AppProgress>(
          AppProgress(unlockedLevels: [1]),
        );
        fakeLevelRepository.countResult = const Error<int>(
          GenericFailure('Count unavailable'),
        );

        // Act
        final result = await useCase(currentLevelId: 1);

        // Assert
        switch (result) {
          case Success(:final value):
            fail('Expected Error, got Success: $value');
          case Error(:final failure):
            expect(failure, isA<GenericFailure>());
        }
        expect(fakeProgressRepository.savedProgress, isNull);
      },
    );

    test(
      'should_return_generic_failure_when_save_progress_fails',
      () async {
        // Arrange
        fakeLevelRepository.countResult = const Success<int>(5);
        fakeProgressRepository.loadResult = const Success<AppProgress>(
          AppProgress(unlockedLevels: [1]),
        );
        fakeProgressRepository.saveResult = const Error<void>(
          GenericFailure('Save unavailable'),
        );

        // Act
        final result = await useCase(currentLevelId: 1);

        // Assert
        switch (result) {
          case Success(:final value):
            fail('Expected Error, got Success: $value');
          case Error(:final failure):
            expect(failure, isA<GenericFailure>());
        }
        expect(
          fakeProgressRepository.savedProgress,
          equals(const AppProgress(unlockedLevels: [1, 2])),
        );
      },
    );

    test(
      'should_return_generic_failure_when_unhandled_exception_occurs',
      () async {
        // Arrange
        fakeProgressRepository.loadExceptionToThrow = Exception('Load boom');

        // Act
        final result = await useCase(currentLevelId: 1);

        // Assert
        switch (result) {
          case Success(:final value):
            fail('Expected Error, got Success: $value');
          case Error(:final failure):
            expect(failure, isA<GenericFailure>());
            expect(failure.message, contains('Load boom'));
        }
        expect(fakeProgressRepository.savedProgress, isNull);
      },
    );
  });
}
