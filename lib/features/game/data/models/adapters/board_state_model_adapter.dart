import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/board_state_model.dart';
import 'package:hive/hive.dart';

/// Hive [TypeAdapter] for [BoardStateModel] (typeId: 2).
class BoardStateModelAdapter extends TypeAdapter<BoardStateModel> {
  @override
  final int typeId = 2;

  @override
  BoardStateModel read(BinaryReader reader) {
    final arrows = reader.readList().cast<ArrowModel>();
    return BoardStateModel(arrows: arrows);
  }

  @override
  void write(BinaryWriter writer, BoardStateModel obj) {
    writer.writeList(obj.arrows);
  }
}
