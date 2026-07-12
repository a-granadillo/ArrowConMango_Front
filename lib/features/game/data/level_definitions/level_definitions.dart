import 'package:arrowconmango_front/features/game/data/models/level_model.dart';

import 'easy_levels.dart';
import 'hard_levels.dart';
import 'level_generator.dart';
import 'medium_levels.dart';

/// The game's level catalogues (Campaign and Endless).
///
/// - `campaignLevels`: 15 handcrafted levels with dense shapes (40-70 arrows).
/// - `generateEndless()`: Dynamic levels powered by [LevelGenerator].
class LevelDefinitions {
  LevelDefinitions._();

  /// The 15 static handcrafted levels for Campaign Mode.
  static final List<LevelModel> campaignLevels = [
    ...EasyLevels.all,
    ...MediumLevels.all,
    ...HardLevels.all,
  ];

  static List<LevelModel> get easyLevels =>
      campaignLevels.where((l) => l.difficulty == 'Easy').toList();

  static List<LevelModel> get mediumLevels =>
      campaignLevels.where((l) => l.difficulty == 'Medium').toList();

  static List<LevelModel> get hardLevels =>
      campaignLevels.where((l) => l.difficulty == 'Hard').toList();

  static LevelModel? getById(int id) {
    for (final level in campaignLevels) {
      if (level.id == id) return level;
    }
    return null;
  }

  /// Generates a random endless level using the procedural generator.
  static LevelModel generateEndless({
    required int id,
    required String difficulty,
    required int seed,
  }) {
    final arrowCount = switch (difficulty) {
      'Easy' => 9,
      'Medium' => 13,
      'Hard' => 18,
      _ => 12,
    };

    return LevelGenerator.generate(
      id: id,
      name: 'Supervivencia $id',
      difficulty: difficulty,
      arrowCount: arrowCount,
      seed: seed,
    );
  }
}
