import 'package:arrowconmango_front/features/game/data/models/board_size_model.dart';
import 'package:hive/hive.dart';

/// Hive [TypeAdapter] for [BoardSizeModel] (typeId: 5).
class BoardSizeModelAdapter extends TypeAdapter<BoardSizeModel> {
  @override
  final int typeId = 5;

  @override
  BoardSizeModel read(BinaryReader reader) {
    final rows = reader.readInt();
    final cols = reader.readInt();
    return BoardSizeModel(rows: rows, cols: cols);
  }

  @override
  void write(BinaryWriter writer, BoardSizeModel obj) {
    writer.writeInt(obj.rows);
    writer.writeInt(obj.cols);
  }
}
