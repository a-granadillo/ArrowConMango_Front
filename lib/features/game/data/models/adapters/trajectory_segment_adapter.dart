import 'package:arrowconmango_front/features/game/data/models/trajectory_segment.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:hive/hive.dart';

/// Hive [TypeAdapter] for [TrajectorySegment] (typeId: 6).
class TrajectorySegmentAdapter extends TypeAdapter<TrajectorySegment> {
  @override
  final int typeId = 6;

  @override
  TrajectorySegment read(BinaryReader reader) {
    final directionIndex = reader.readInt();
    final length = reader.readInt();
    return TrajectorySegment(
      direction: CardinalDirection.values[directionIndex],
      length: length,
    );
  }

  @override
  void write(BinaryWriter writer, TrajectorySegment obj) {
    writer.writeInt(obj.direction.index);
    writer.writeInt(obj.length);
  }
}
