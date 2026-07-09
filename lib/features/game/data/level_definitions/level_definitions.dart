import 'package:arrowconmango_front/features/game/data/models/level_model.dart';

import 'easy_levels.dart';
import 'hard_levels.dart';
import 'medium_levels.dart';

class LevelDefinitions {
  LevelDefinitions._();

  static final List<LevelModel> allLevels = [
    ...EasyLevels.all,
    ...MediumLevels.all,
    ...HardLevels.all,
  ];

  static final List<LevelModel> easyLevels = EasyLevels.all;

  static final List<LevelModel> mediumLevels = MediumLevels.all;

  static final List<LevelModel> hardLevels = HardLevels.all;

  static LevelModel? getById(int id) {
    for (final level in allLevels) {
      if (level.id == id) return level;
    }
    return null;
  }
}
