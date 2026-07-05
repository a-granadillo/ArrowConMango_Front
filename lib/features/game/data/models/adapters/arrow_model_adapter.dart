import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';
import 'package:hive/hive.dart';

/// Hive [TypeAdapter] for [ArrowModel] (typeId: 1).
class ArrowModelAdapter extends TypeAdapter<ArrowModel> {
  @override
  final int typeId = 1;

  @override
  ArrowModel read(BinaryReader reader) {
    final id = reader.readString();
    final nodes = reader.readList().cast<NodeModel>();
    final direction = reader.readString();
    return ArrowModel(
      id: id,
      nodes: nodes,
      direction: direction,
    );
  }

  @override
  void write(BinaryWriter writer, ArrowModel obj) {
    writer.writeString(obj.id);
    writer.writeList(obj.nodes);
    writer.writeString(obj.direction);
  }
}
