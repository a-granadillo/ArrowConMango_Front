import 'package:arrowconmango_front/features/game/data/models/adapters/app_progress_model_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/adapters/arrow_model_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/adapters/arrow_trajectory_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/adapters/board_size_model_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/adapters/board_state_model_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/adapters/level_model_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/adapters/node_model_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/adapters/trajectory_segment_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/app_progress_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Centralised Hive initialisation and box registration.
///
/// Call [initialise] once at application startup before accessing
/// any repository that depends on Hive boxes.
class HiveConfig {
  static const String levelsBoxName = 'levels_v2';
  static const String progressBoxName = 'progress';

  HiveConfig._();

  /// Initialises Hive for Flutter, registers all model adapters,
  /// and opens the boxes required by the game feature.
  static Future<void> initialise() async {
    await Hive.initFlutter();
    registerAdapters();
    await Hive.openBox<LevelModel>(levelsBoxName);
    await Hive.openBox<AppProgressModel>(progressBoxName);
  }

  /// Registers all Hive type adapters used by the game models.
  ///
  /// Public so tests can register adapters after calling [Hive.init] with a
  /// temporary directory.
  static void registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NodeModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ArrowModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(BoardStateModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(LevelModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AppProgressModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(TrajectorySegmentAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(ArrowTrajectoryAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(BoardSizeModelAdapter());
    }
  }
}
