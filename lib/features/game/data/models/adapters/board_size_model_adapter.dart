import 'package:arrowconmango_front/features/game/data/models/board_size_model.dart';
import 'package:hive/hive.dart';

/// Hive [TypeAdapter] for [BoardSizeModel] (typeId: 8).
class BoardSizeModelAdapter extends TypeAdapter<BoardSizeModel> {
  @override
  final int typeId = 8;

  @override
  BoardSizeModel read(BinaryReader reader) {
    return BoardSizeModel(
      rows: reader.readInt(),
      cols: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, BoardSizeModel obj) {
    writer.writeInt(obj.rows);
    writer.writeInt(obj.cols);
  }
}
