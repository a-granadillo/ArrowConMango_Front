import 'package:arrowconmango_front/features/game/data/models/app_progress_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_best_model.dart';
import 'package:hive/hive.dart';

/// Hive [TypeAdapter] for [AppProgressModel] (typeId: 4).
///
/// Byte layout is unchanged from the previous `scores` field: both are
/// `[currentLevel:int][completedLevels:list][hasX:bool][x:map?]`. Every
/// pre-existing record has `hasX == false` (nothing in production ever
/// wrote a non-null `scores`), so the `readMap()` branch was never
/// exercised and old records deserialize correctly as `best == null` under
/// this adapter — see the layout-compatibility test.
class AppProgressModelAdapter extends TypeAdapter<AppProgressModel> {
  @override
  final int typeId = 4;

  @override
  AppProgressModel read(BinaryReader reader) {
    final currentLevel = reader.readInt();
    final completedLevels = reader.readList().cast<int>();
    final hasBest = reader.readBool();
    Map<int, LevelBestModel>? best;
    if (hasBest) {
      best = reader.readMap().map(
        (key, value) => MapEntry(key as int, value as LevelBestModel),
      );
    }
    return AppProgressModel(
      currentLevel: currentLevel,
      completedLevels: completedLevels,
      best: best,
    );
  }

  @override
  void write(BinaryWriter writer, AppProgressModel obj) {
    writer.writeInt(obj.currentLevel);
    writer.writeList(obj.completedLevels);
    final best = obj.best;
    writer.writeBool(best != null);
    if (best != null) {
      writer.writeMap(best);
    }
  }
}
