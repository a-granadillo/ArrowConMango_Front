import 'package:arrowconmango_front/features/game/data/models/level_model.dart';

import 'level_generator.dart';

/// The game's level catalogues (Campaign and Endless).
///
/// - `campaignLevels`: 15 procedurally generated levels (guaranteed solvable).
/// - `generateEndless()`: Dynamic levels for endless mode.
class LevelDefinitions {
  LevelDefinitions._();

  /// Level specifications: (name, difficulty, config, seed)
  static const List<(String, String, LevelConfig, int)> _specs = [
    // Easy levels (6x6, 15 arrows, mostly straight and L-shapes)
    ('Mango Verde', 'Easy', LevelConfig.easy, 1007),
    ('Semilla Tierna', 'Easy', LevelConfig.easy, 2007),
    ('Brote Nuevo', 'Easy', LevelConfig.easy, 3007),
    ('Hoja Fresca', 'Easy', LevelConfig.easy, 4007),
    ('Sol Naciente', 'Easy', LevelConfig.easy, 5007),
    
    // Medium levels (8x8, 30 arrows, mix of all shapes)
    ('Pulpa Dulce', 'Medium', LevelConfig.medium, 6007),
    ('Néctar Maduro', 'Medium', LevelConfig.medium, 7007),
    ('Cosecha Media', 'Medium', LevelConfig.medium, 8007),
    ('Fibra Jugosa', 'Medium', LevelConfig.medium, 9007),
    ('Aroma Tropical', 'Medium', LevelConfig.medium, 10007),
    
    // Hard levels (12x12, 60 arrows, complex shapes)
    ('Piel Dorada', 'Hard', LevelConfig.hard, 11007),
    ('Hueso Duro', 'Hard', LevelConfig.hard, 12007),
    ('Corazón del Mango', 'Hard', LevelConfig.hard, 13007),
    ('Huerto Salvaje', 'Hard', LevelConfig.hard, 14007),
    ('Rey Mango', 'Hard', LevelConfig.hard, 15007),
  ];

  /// The 15 campaign levels (procedurally generated, guaranteed solvable).
  static final List<LevelModel> campaignLevels = [
    for (var i = 0; i < _specs.length; i++)
      LevelGenerator.generate(
        id: i + 1,
        name: _specs[i].$1,
        difficulty: _specs[i].$2,
        config: _specs[i].$3,
        seed: _specs[i].$4,
      ),
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
    final config = switch (difficulty) {
      'Easy' => LevelConfig.easy,
      'Medium' => LevelConfig.medium,
      'Hard' => LevelConfig.hard,
      _ => LevelConfig.medium,
    };

    return LevelGenerator.generate(
      id: id,
      name: 'Supervivencia $id',
      difficulty: difficulty,
      config: config,
      seed: seed,
    );
  }
}
