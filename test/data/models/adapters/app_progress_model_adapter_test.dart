import 'dart:io';

import 'package:arrowconmango_front/features/game/data/models/adapters/app_progress_model_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/app_progress_model.dart';
import 'package:hive/hive.dart';
import 'package:test/test.dart';

/// Write-only adapter that replicates the byte layout AppProgressModelAdapter
/// used *before* `scores` was renamed to `best`:
/// `[currentLevel:int][completedLevels:list][hasScores:bool]`, always
/// writing `false` for `hasScores` — every pre-existing record in
/// production had a null `scores`, so this is the only shape that ever
/// existed on disk.
class _LegacyAppProgressModelAdapter extends TypeAdapter<AppProgressModel> {
  @override
  final int typeId = 4;

  @override
  AppProgressModel read(BinaryReader reader) => throw UnimplementedError(
        'write-only: legacy records were never read back by this adapter',
      );

  @override
  void write(BinaryWriter writer, AppProgressModel obj) {
    writer.writeInt(obj.currentLevel);
    writer.writeList(obj.completedLevels);
    writer.writeBool(false); // legacy hasScores, always false in production
  }
}

void main() {
  test(
    'should_read_a_legacy_record_written_without_best_as_best_null',
    () async {
      // Arrange — write a record using the pre-rename byte layout.
      final dir = await Directory.systemTemp.createTemp('hive_legacy_test');
      Hive.init(dir.path);
      Hive.registerAdapter(_LegacyAppProgressModelAdapter());

      final legacyBox =
          await Hive.openBox<AppProgressModel>('legacy_progress');
      await legacyBox.put(
        'app_progress',
        const AppProgressModel(currentLevel: 5, completedLevels: [1, 2, 3]),
      );
      await legacyBox.close();

      // Act — reopen with the real, current adapter (post-rename).
      Hive.registerAdapter(AppProgressModelAdapter(), override: true);
      final reopenedBox =
          await Hive.openBox<AppProgressModel>('legacy_progress');
      final restored = reopenedBox.get('app_progress');

      // Assert — old records deserialize correctly, with best == null.
      expect(restored, isNotNull);
      expect(restored!.currentLevel, equals(5));
      expect(restored.completedLevels, equals([1, 2, 3]));
      expect(restored.best, isNull);

      await reopenedBox.close();
      await dir.delete(recursive: true);
    },
  );
}
