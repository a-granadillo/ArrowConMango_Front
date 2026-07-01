import 'package:arrowconmango_front/features/game/data/models/app_progress_model.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/app_progress_mapper.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:test/test.dart';

void main() {
  const mapper = AppProgressMapper();

  group('AppProgressMapper', () {
    test('should_convert_app_progress_model_to_entity', () {
      // Arrange
      const model = AppProgressModel(
        currentLevel: 3,
        completedLevels: [1, 2],
        scores: {'1': 100, '2': 150},
      );

      // Act
      final entity = mapper.toEntity(model);

      // Assert
      expect(entity.unlockedLevels, equals([1, 2]));
      expect(entity.currentToken, equals('3'));
    });

    test('should_convert_app_progress_entity_to_model', () {
      // Arrange
      const entity = AppProgress(
        unlockedLevels: [1, 3],
        currentToken: '3',
      );

      // Act
      final model = mapper.toModel(entity);

      // Assert
      expect(model.currentLevel, equals(3));
      expect(model.completedLevels, equals([1, 3]));
    });

    test('should_round_trip_model_through_entity_when_scores_are_empty', () {
      // Arrange
      const original = AppProgressModel(
        currentLevel: 2,
        completedLevels: [1, 2],
        scores: {},
      );

      // Act
      final roundTripped = mapper.toModel(mapper.toEntity(original));

      // Assert
      expect(roundTripped.currentLevel, equals(original.currentLevel));
      expect(roundTripped.completedLevels, equals(original.completedLevels));
    });

    test('should_handle_empty_completed_levels_and_scores', () {
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
      expect(entity.currentToken, equals('0'));
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
