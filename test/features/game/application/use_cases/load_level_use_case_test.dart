import 'package:arrowconmango_front/features/game/application/use_cases/load_level_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_level_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:flutter_test/flutter_test.dart';

/// Manual mock for [ILevelRepository].
///
/// Only [getLevelDefinition] is exercised by [LoadLevelUseCase]; the other
/// contract methods throw [UnimplementedError] if accidentally invoked.
class MockLevelRepository implements ILevelRepository {
  /// Pre-configured result returned by [getLevelDefinition].
  Result<Level>? definitionResult;

  /// Captures the [levelId] passed into [getLevelDefinition].
  int? requestedLevelId;

  @override
  Future<Result<int>> getLevelCount() async {
    throw UnimplementedError('getLevelCount() should not be called');
  }

  @override
  Future<Result<GameSession>> loadLevel(int levelId) async {
    throw UnimplementedError('loadLevel() should not be called');
  }

  @override
  Future<Result<Level>> getLevelDefinition(int levelId) async {
    requestedLevelId = levelId;
    return definitionResult!;
  }
}

void main() {
  group('LoadLevelUseCase', () {
    late MockLevelRepository mockRepository;
    late LoadLevelUseCase useCase;
    late Level testLevel;

    setUp(() {
      mockRepository = MockLevelRepository();
      useCase = LoadLevelUseCase(mockRepository);
      testLevel = Level(
        levelId: 1,
        templateBoard: BoardState(arrows: const []),
      );
    });

    test(
      'should_return_the_level_definition_when_the_repository_succeeds',
      () async {
        // Arrange
        mockRepository.definitionResult = Success(testLevel);

        // Act
        final result = await useCase(levelId: 1);

        // Assert
        expect(result, isA<Success<Level>>());
        expect((result as Success<Level>).value, equals(testLevel));
        expect(mockRepository.requestedLevelId, equals(1));
      },
    );

    test(
      'should_return_an_error_when_the_repository_fails',
      () async {
        // Arrange
        const failure = GenericFailure('Level not found');
        mockRepository.definitionResult = Error(failure);

        // Act
        final result = await useCase(levelId: 99);

        // Assert
        expect(result, isA<Error<Level>>());
        expect((result as Error<Level>).failure, equals(failure));
        expect(mockRepository.requestedLevelId, equals(99));
      },
    );
  });
}
