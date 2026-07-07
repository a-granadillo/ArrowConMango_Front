import 'package:arrowconmango_front/features/game/application/dtos/level_summary.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/get_level_list_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes/fake_level_repository.dart';
import '../../../../helpers/fakes/fake_progress_repository.dart';

void main() {
  group('GetLevelListUseCase', () {
    late FakeLevelRepository fakeLevelRepository;
    late FakeProgressRepository fakeProgressRepository;
    late GetLevelListUseCase useCase;

    setUp(() {
      fakeLevelRepository = FakeLevelRepository();
      fakeProgressRepository = FakeProgressRepository();
      useCase = GetLevelListUseCase(
        fakeLevelRepository,
        fakeProgressRepository,
      );
    });

    test(
      'should_return_unlocked_level_summaries_when_repositories_succeed',
      () async {
        // Arrange
        fakeLevelRepository.countResult = const Success<int>(3);
        fakeProgressRepository.loadResult = const Success<AppProgress>(
          AppProgress(unlockedLevels: [1, 3]),
        );

        // Act
        final result = await useCase();

        // Assert
        switch (result) {
          case Success(:final value):
            expect(value.length, equals(3));
            expect(
              value,
              equals(const [
                LevelSummary(levelId: 1, isUnlocked: true),
                LevelSummary(levelId: 2, isUnlocked: false),
                LevelSummary(levelId: 3, isUnlocked: true),
              ]),
            );
          case Error(:final failure):
            fail('Expected Success, got Error: $failure');
        }
      },
    );

    test(
      'should_return_generic_failure_when_level_count_fails',
      () async {
        // Arrange
        fakeLevelRepository.countResult = const Error<int>(
          GenericFailure('Level count unavailable'),
        );

        // Act
        final result = await useCase();

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
      'should_return_generic_failure_when_progress_load_fails',
      () async {
        // Arrange
        fakeLevelRepository.countResult = const Success<int>(2);
        fakeProgressRepository.loadResult = const Error<AppProgress>(
          GenericFailure('Progress unavailable'),
        );

        // Act
        final result = await useCase();

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
      'should_return_generic_failure_when_level_count_throws_exception',
      () async {
        // Arrange
        fakeLevelRepository.countExceptionToThrow = Exception('Count boom');

        // Act
        final result = await useCase();

        // Assert
        switch (result) {
          case Success(:final value):
            fail('Expected Error, got Success: $value');
          case Error(:final failure):
            expect(failure, isA<GenericFailure>());
            expect(failure.message, contains('Count boom'));
        }
      },
    );

    test(
      'should_return_generic_failure_when_progress_load_throws_exception',
      () async {
        // Arrange
        fakeLevelRepository.countResult = const Success<int>(2);
        fakeProgressRepository.loadExceptionToThrow = Exception('Progress boom');

        // Act
        final result = await useCase();

        // Assert
        switch (result) {
          case Success(:final value):
            fail('Expected Error, got Success: $value');
          case Error(:final failure):
            expect(failure, isA<GenericFailure>());
            expect(failure.message, contains('Progress boom'));
        }
      },
    );
  });
}
