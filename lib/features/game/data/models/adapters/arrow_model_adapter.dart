import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/arrow_trajectory.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';
import 'package:hive/hive.dart';

/// Hive [TypeAdapter] for [ArrowModel] (typeId: 1).
class ArrowModelAdapter extends TypeAdapter<ArrowModel> {
  @override
  final int typeId = 1;

  @override
  ArrowModel read(BinaryReader reader) {
    final id = reader.readString();
    final startNode = reader.read() as NodeModel;
    final trajectory = reader.read() as ArrowTrajectory;
    return ArrowModel(
      id: id,
      startNode: startNode,
      trajectory: trajectory,
    );
  }

  @override
  void write(BinaryWriter writer, ArrowModel obj) {
    writer.writeString(obj.id);
    writer.write(obj.startNode);
    writer.write(obj.trajectory);
  }
}
