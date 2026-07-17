import 'package:arrowconmango_front/features/game/data/models/level_best_model.dart';
import 'package:hive/hive.dart';

/// Hive [TypeAdapter] for [LevelBestModel] (typeId: 5).
class LevelBestModelAdapter extends TypeAdapter<LevelBestModel> {
  @override
  final int typeId = 5;

  @override
  LevelBestModel read(BinaryReader reader) {
    return LevelBestModel(
      moves: reader.readInt(),
      timeElapsedSeconds: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, LevelBestModel obj) {
    writer.writeInt(obj.moves);
    writer.writeInt(obj.timeElapsedSeconds);
  }
}
