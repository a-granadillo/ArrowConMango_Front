import 'package:arrowconmango_front/features/game/data/models/adapters/app_progress_model_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/adapters/arrow_model_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/adapters/board_state_model_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/adapters/level_model_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/adapters/node_model_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/app_progress_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Centralised Hive initialisation and box registration.
///
/// Call [initialise] once at application startup before accessing
/// any repository that depends on Hive boxes.
class HiveConfig {
  static const String levelsBoxName = 'levels';
  static const String progressBoxName = 'progress';

  HiveConfig._();

  /// Initialises Hive for Flutter, registers all model adapters,
  /// and opens the boxes required by the game feature.
  static Future<void> initialise() async {
    await Hive.initFlutter();
    _registerAdapters();
    await Hive.openBox<LevelModel>(levelsBoxName);
    await Hive.openBox<AppProgressModel>(progressBoxName);
  }

  static void _registerAdapters() {
    Hive.registerAdapter(NodeModelAdapter());
    Hive.registerAdapter(ArrowModelAdapter());
    Hive.registerAdapter(BoardStateModelAdapter());
    Hive.registerAdapter(LevelModelAdapter());
    Hive.registerAdapter(AppProgressModelAdapter());
  }
}
