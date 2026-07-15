import 'package:arrowconmango_front/features/game/data/models/arrow_trajectory.dart';
import 'package:arrowconmango_front/features/game/data/models/trajectory_segment.dart';
import 'package:hive/hive.dart';

/// Hive [TypeAdapter] for [ArrowTrajectory] (typeId: 7).
class ArrowTrajectoryAdapter extends TypeAdapter<ArrowTrajectory> {
  @override
  final int typeId = 7;

  @override
  ArrowTrajectory read(BinaryReader reader) {
    final segments = reader.readList().cast<TrajectorySegment>();
    return ArrowTrajectory(segments: segments);
  }

  @override
  void write(BinaryWriter writer, ArrowTrajectory obj) {
    writer.writeList(obj.segments);
  }
}
