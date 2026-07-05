import 'package:arrowconmango_front/features/game/data/models/node_model.dart';
import 'package:hive/hive.dart';

/// Hive [TypeAdapter] for [NodeModel] (typeId: 0).
class NodeModelAdapter extends TypeAdapter<NodeModel> {
  @override
  final int typeId = 0;

  @override
  NodeModel read(BinaryReader reader) {
    final row = reader.readInt();
    final col = reader.readInt();
    return NodeModel(row: row, col: col);
  }

  @override
  void write(BinaryWriter writer, NodeModel obj) {
    writer.writeInt(obj.row);
    writer.writeInt(obj.col);
  }
}
