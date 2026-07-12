import 'package:arrowconmango_front/core/di/progress_seed.dart';
import 'package:arrowconmango_front/features/game/data/models/app_progress_model.dart';
import 'package:arrowconmango_front/features/game/data/repositories/hive_progress_repository.dart';
import 'package:hive/hive.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';

class _FakeProgressBox extends Fake implements Box<AppProgressModel> {
  final Map<dynamic, AppProgressModel> _data = {};

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  AppProgressModel? get(dynamic key, {AppProgressModel? defaultValue}) {
    return _data.containsKey(key) ? _data[key] : defaultValue;
  }

  @override
  Future<void> put(dynamic key, AppProgressModel value) async {
    _data[key] = value;
  }
}

void main() {
  group('seedProgressIfEmpty', () {
    test('should_unlock_level_1_when_box_is_empty', () {
      // Arrange
      final box = _FakeProgressBox();

      // Act
      seedProgressIfEmpty(box);

      // Assert
      final saved = box.get(HiveProgressRepository.progressKey);
      expect(saved, isNotNull);
      expect(saved!.completedLevels, contains(1));
      expect(saved.currentLevel, 1);
    });

    test('should_not_overwrite_existing_progress', () async {
      // Arrange
      final box = _FakeProgressBox();
      await box.put(
        HiveProgressRepository.progressKey,
        const AppProgressModel(currentLevel: 5, completedLevels: [1, 2, 3]),
      );

      // Act
      seedProgressIfEmpty(box);

      // Assert: the returning player's real progress is untouched.
      final saved = box.get(HiveProgressRepository.progressKey);
      expect(saved!.completedLevels, [1, 2, 3]);
      expect(saved.currentLevel, 5);
    });
  });
}
