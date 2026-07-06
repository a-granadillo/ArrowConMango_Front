import 'package:arrowconmango_front/features/game/data/models/app_progress_model.dart';
import 'package:hive/hive.dart';

/// Hive [TypeAdapter] for [AppProgressModel] (typeId: 4).
class AppProgressModelAdapter extends TypeAdapter<AppProgressModel> {
  @override
  final int typeId = 4;

  @override
  AppProgressModel read(BinaryReader reader) {
    final currentLevel = reader.readInt();
    final completedLevels = reader.readList().cast<int>();
    final hasScores = reader.readBool();
    Map<String, int>? scores;
    if (hasScores) {
      scores = reader.readMap().map(
        (key, value) => MapEntry(key as String, value as int),
      );
    }
    return AppProgressModel(
      currentLevel: currentLevel,
      completedLevels: completedLevels,
      scores: scores,
    );
  }

  @override
  void write(BinaryWriter writer, AppProgressModel obj) {
    writer.writeInt(obj.currentLevel);
    writer.writeList(obj.completedLevels);
    final scores = obj.scores;
    writer.writeBool(scores != null);
    if (scores != null) {
      writer.writeMap(scores);
    }
  }
}
