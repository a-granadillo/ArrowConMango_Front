import 'package:arrowconmango_front/features/game/data/models/level_model.dart';

import 'easy_levels.dart';
import 'hard_levels.dart';
import 'medium_levels.dart';

/// Central registry for all 15 game levels.
///
/// Levels are grouped by difficulty:
///   - Easy: levels 1-5 (10-20 arrows)
///   - Medium: levels 6-10 (21-40 arrows)
///   - Hard: levels 11-15 (41-70 arrows)
class LevelDefinitions {
  LevelDefinitions._();

  /// All 15 levels in ascending order.
  static final List<LevelModel> allLevels = [
    ...EasyLevels.all,
    ...MediumLevels.all,
    ...HardLevels.all,
  ];

  /// Easy levels only.
  static final List<LevelModel> easyLevels = EasyLevels.all;

  /// Medium levels only.
  static final List<LevelModel> mediumLevels = MediumLevels.all;

  /// Hard levels only.
  static final List<LevelModel> hardLevels = HardLevels.all;

  /// Returns the level with the given [id] or null if not found.
  static LevelModel? getById(int id) {
    for (final level in allLevels) {
      if (level.id == id) return level;
    }
    return null;
  }
}
