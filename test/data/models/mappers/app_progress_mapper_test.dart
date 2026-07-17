import 'package:arrowconmango_front/features/game/data/models/app_progress_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_best_model.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/app_progress_mapper.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level_best.dart';
import 'package:test/test.dart';

void main() {
  const mapper = AppProgressMapper();

  group('AppProgressMapper', () {
    test('should_convert_app_progress_model_to_entity', () {
      // Arrange
      const model = AppProgressModel(
        currentLevel: 3,
        completedLevels: [1, 2],
        best: {1: LevelBestModel(moves: 5, timeElapsedSeconds: 20)},
      );

      // Act
      final entity = mapper.toEntity(model);

      // Assert
      expect(entity.unlockedLevels, equals([1, 2]));
      expect(entity.currentLevel, equals(3));
      expect(
        entity.best,
        equals({1: const LevelBest(moves: 5, timeElapsedSeconds: 20)}),
      );
    });

    test('should_convert_app_progress_entity_to_model', () {
      // Arrange
      const entity = AppProgress(
        unlockedLevels: [1, 3],
        currentLevel: 3,
        best: {2: LevelBest(moves: 4, timeElapsedSeconds: 15)},
      );

      // Act
      final model = mapper.toModel(entity);

      // Assert
      expect(model.currentLevel, equals(3));
      expect(model.completedLevels, equals([1, 3]));
      expect(
        model.best,
        equals({2: const LevelBestModel(moves: 4, timeElapsedSeconds: 15)}),
      );
    });

    test('should_round_trip_model_through_entity_when_best_is_empty', () {
      // Arrange
      const original = AppProgressModel(
        currentLevel: 2,
        completedLevels: [1, 2],
        best: {},
      );

      // Act
      final roundTripped = mapper.toModel(mapper.toEntity(original));

      // Assert
      expect(roundTripped.currentLevel, equals(original.currentLevel));
      expect(roundTripped.completedLevels, equals(original.completedLevels));
      expect(roundTripped.best, isNull);
    });

    test('should_handle_empty_completed_levels_and_best', () {
      // Arrange
      const original = AppProgressModel(
        currentLevel: 0,
        completedLevels: [],
      );

      // Act
      final entity = mapper.toEntity(original);
      final roundTripped = mapper.toModel(entity);

      // Assert
      expect(entity.unlockedLevels, isEmpty);
      expect(entity.currentLevel, equals(0));
      expect(roundTripped.completedLevels, isEmpty);
      expect(roundTripped.currentLevel, equals(0));
    });

    test('should_sort_completed_levels_when_converting_to_entity', () {
      // Arrange
      const model = AppProgressModel(
        currentLevel: 5,
        completedLevels: [3, 1, 2],
      );

      // Act
      final entity = mapper.toEntity(model);

      // Assert
      expect(entity.unlockedLevels, equals([1, 2, 3]));
    });
  });
}
