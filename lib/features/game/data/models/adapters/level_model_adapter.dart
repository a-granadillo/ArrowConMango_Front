import 'package:arrowconmango_front/features/game/data/models/board_state_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'package:hive/hive.dart';

/// Hive [TypeAdapter] for [LevelModel] (typeId: 3).
class LevelModelAdapter extends TypeAdapter<LevelModel> {
  @override
  final int typeId = 3;

  @override
  LevelModel read(BinaryReader reader) {
    final id = reader.readInt();
    final name = reader.readString();
    final difficulty = reader.readString();
    final boardState = reader.read() as BoardStateModel;
    return LevelModel(
      id: id,
      name: name,
      difficulty: difficulty,
      boardState: boardState,
    );
  }

  @override
  void write(BinaryWriter writer, LevelModel obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.difficulty);
    writer.write(obj.boardState);
  }
}
