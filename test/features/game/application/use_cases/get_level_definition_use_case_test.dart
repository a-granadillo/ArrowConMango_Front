import 'package:arrowconmango_front/features/game/application/use_cases/get_level_definition_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes/fake_level_repository.dart';

void main() {
  group('GetLevelDefinitionUseCase', () {
    late FakeLevelRepository fakeRepository;
    late GetLevelDefinitionUseCase useCase;
    late Level testLevel;

    setUp(() {
      fakeRepository = FakeLevelRepository();
      useCase = GetLevelDefinitionUseCase(fakeRepository);
      testLevel = Level(
        levelId: 1,
        rows: 7,
        cols: 7,
        templateBoard: BoardState(arrows: const []),
      );
    });

    test(
      'should_return_level_definition_when_level_id_is_valid_and_repository_succeeds',
      () async {
        // Arrange
        fakeRepository.definitionResult = Success(testLevel);

        // Act
        final result = await useCase(levelId: 1);

        // Assert
        switch (result) {
          case Success(:final value):
            expect(value, equals(testLevel));
          case Error(:final failure):
            fail('Expected Success, got Error: $failure');
        }
        expect(fakeRepository.requestedLevelId, equals(1));
      },
    );

    test(
      'should_return_error_when_level_id_is_invalid',
      () async {
        // Arrange
        const invalidLevelId = 0;

        // Act
        final result = await useCase(levelId: invalidLevelId);

        // Assert
        switch (result) {
          case Success(:final value):
            fail('Expected Error, got Success: $value');
          case Error(:final failure):
            expect(failure, isA<GenericFailure>());
        }
        expect(fakeRepository.requestedLevelId, isNull);
      },
    );

    test(
      'should_return_error_when_level_id_is_negative',
      () async {
        // Arrange
        const negativeLevelId = -5;

        // Act
        final result = await useCase(levelId: negativeLevelId);

        // Assert
        switch (result) {
          case Success(:final value):
            fail('Expected Error, got Success: $value');
          case Error(:final failure):
            expect(failure, isA<GenericFailure>());
        }
        expect(fakeRepository.requestedLevelId, isNull);
      },
    );

    test(
      'should_return_error_when_repository_returns_a_failure',
      () async {
        // Arrange
        const expectedFailure = GenericFailure('Level not found');
        fakeRepository.definitionResult = Error(expectedFailure);

        // Act
        final result = await useCase(levelId: 99);

        // Assert
        switch (result) {
          case Success(:final value):
            fail('Expected Error, got Success: $value');
          case Error(:final failure):
            expect(failure, equals(expectedFailure));
        }
        expect(fakeRepository.requestedLevelId, equals(99));
      },
    );

    test(
      'should_return_generic_failure_when_repository_throws_unhandled_exception',
      () async {
        // Arrange
        fakeRepository.definitionExceptionToThrow = Exception('Unexpected load error');

        // Act
        final result = await useCase(levelId: 5);

        // Assert
        switch (result) {
          case Success(:final value):
            fail('Expected Error, got Success: $value');
          case Error(:final failure):
            expect(failure, isA<GenericFailure>());
            expect(failure.message, contains('Unexpected load error'));
        }
        expect(fakeRepository.requestedLevelId, equals(5));
      },
    );
  });
}
