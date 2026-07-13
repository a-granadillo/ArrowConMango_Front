import 'package:arrowconmango_front/features/game/data/models/level_model.dart';

import 'level_generator.dart';

/// The game's level catalogues (Campaign and Endless).
///
/// - `campaignLevels`: 15 procedurally generated levels (guaranteed solvable).
/// - `generateEndless()`: Dynamic levels for endless mode.
class LevelDefinitions {
  LevelDefinitions._();

  /// Level specifications: (name, difficulty, arrowCount, seed)
  static const List<(String, String, int, int)> _specs = [
    ('Mango Verde', 'Easy', 7, 1007),
    ('Semilla Tierna', 'Easy', 8, 2007),
    ('Brote Nuevo', 'Easy', 8, 3007),
    ('Hoja Fresca', 'Easy', 9, 4007),
    ('Sol Naciente', 'Easy', 9, 5007),
    ('Pulpa Dulce', 'Medium', 11, 6007),
    ('Néctar Maduro', 'Medium', 12, 7007),
    ('Cosecha Media', 'Medium', 12, 8007),
    ('Fibra Jugosa', 'Medium', 13, 9007),
    ('Aroma Tropical', 'Medium', 13, 10007),
    ('Piel Dorada', 'Hard', 15, 11007),
    ('Hueso Duro', 'Hard', 16, 12007),
    ('Corazón del Mango', 'Hard', 16, 13007),
    ('Huerto Salvaje', 'Hard', 17, 14007),
    ('Rey Mango', 'Hard', 18, 15007),
  ];

  /// The 15 campaign levels (procedurally generated, guaranteed solvable).
  static final List<LevelModel> campaignLevels = [
    for (var i = 0; i < _specs.length; i++)
      LevelGenerator.generate(
        id: i + 1,
        name: _specs[i].$1,
        difficulty: _specs[i].$2,
        arrowCount: _specs[i].$3,
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
