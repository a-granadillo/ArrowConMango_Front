import 'package:test/test.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/data/models/app_progress_model.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/app_progress_mapper.dart';

void main() {
  group('AppProgressMapper', () {
    test('toModel_converts_entity_to_model', () {
      // Arrange
      final entity = AppProgress(
        unlockedLevels: [1, 2, 3],
        currentToken: 'abc123',
      );

      // Act
      final model = AppProgressMapper.toModel(entity);

      // Assert
      expect(model.unlockedLevels, equals([1, 2, 3]));
      expect(model.currentToken, equals('abc123'));
    });

    test('toEntity_converts_model_to_entity', () {
      // Arrange
      final model = AppProgressModel(
        unlockedLevels: [1, 5, 10],
        currentToken: 'xyz789',
      );

      // Act
      final entity = AppProgressMapper.toEntity(model);

      // Assert
      expect(entity.unlockedLevels, equals([1, 5, 10]));
      expect(entity.currentToken, equals('xyz789'));
    });

    test('roundtrip_entity_to_model_to_entity', () {
      // Arrange
      final original = AppProgress(
        unlockedLevels: [1, 2, 3, 4, 5],
        currentToken: 'token123',
      );

      // Act
      final model = AppProgressMapper.toModel(original);
      final restored = AppProgressMapper.toEntity(model);

      // Assert
      expect(restored.unlockedLevels, equals(original.unlockedLevels));
      expect(restored.currentToken, equals(original.currentToken));
    });

    test('model_serialization_toMap_fromMap', () {
      // Arrange
      final model = AppProgressModel(
        unlockedLevels: [1, 2, 3],
        currentToken: 'test-token',
      );

      // Act
      final map = model.toMap();
      final restored = AppProgressModel.fromMap(map);

      // Assert
      expect(restored.unlockedLevels, equals([1, 2, 3]));
      expect(restored.currentToken, equals('test-token'));
    });

    test('handles_empty_unlocked_levels', () {
      // Arrange
      final entity = AppProgress(
        unlockedLevels: [],
        currentToken: '',
      );

      // Act
      final model = AppProgressMapper.toModel(entity);
      final restored = AppProgressMapper.toEntity(model);

      // Assert
      expect(restored.unlockedLevels, isEmpty);
      expect(restored.currentToken, isEmpty);
    });
  });
}
