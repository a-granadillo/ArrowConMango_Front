import 'package:hive/hive.dart';

import '../features/game/data/models/level_model.dart';
import 'database/hive_config.dart';

/// App-wide constants derived from the content catalogue.
///
/// Reads from the already-open `levels_v2` Hive box rather than the
/// code-defined catalogue, so it never forces level (re)generation.
abstract final class AppInfo {
  /// Total number of playable levels.
  static int get totalLevels =>
      Hive.box<LevelModel>(HiveConfig.levelsBoxName).length;
}
