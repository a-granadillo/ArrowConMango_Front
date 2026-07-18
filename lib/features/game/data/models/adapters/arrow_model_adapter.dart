import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/arrow_trajectory.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';
import 'package:hive/hive.dart';

/// Hive [TypeAdapter] for [ArrowModel] (typeId: 1).
///
/// Binary layout (v2): `id(String)`, `startNode(NodeModel)`, `trajectory(ArrowTrajectory)`.
///
/// **Breaking change from v1**: The previous layout stored a flat node list and
/// a direction string. Data written with the v1 adapter is incompatible with
/// this version. A full data reset is required on upgrade.
class ArrowModelAdapter extends TypeAdapter<ArrowModel> {
  @override
  final int typeId = 1;

  @override
  ArrowModel read(BinaryReader reader) {
    try {
      final id = reader.readString();
      final startNode = reader.read() as NodeModel;
      final trajectory = reader.read() as ArrowTrajectory;
      return ArrowModel(
        id: id,
        startNode: startNode,
        trajectory: trajectory,
      );
    } catch (e) {
      throw HiveError(
        'Failed to deserialize ArrowModel — data may have been written '
        'with an incompatible adapter version. A data reset is required.',
      );
    }
  }

  @override
  void write(BinaryWriter writer, ArrowModel obj) {
    writer.writeString(obj.id);
    writer.write(obj.startNode);
    writer.write(obj.trajectory);
  }
}
