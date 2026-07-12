import 'package:arrowconmango_front/features/game/data/models/level_model.dart';

import 'level_generator.dart';

/// The game's 15-level catalogue.
///
/// Levels are produced by [LevelGenerator] — a deterministic, provably-solvable
/// generator in the reference design's style (9×12 board, thin arrows with 90°
/// bends). Ids 1/6/11 carry the reference design's tier names (Mango Verde /
/// Pulpa Dulce / Piel Dorada). Difficulty escalates with the arrow count.
///
/// Determinism: each level uses a fixed seed, so every install seeds the same
/// boards into Hive. Solvability is guaranteed by construction and verified by
/// `test/data/level_solvability_test.dart`.
class LevelDefinitions {
  LevelDefinitions._();

  /// (name, difficulty, arrowCount) per level id (1-based).
  static const List<(String, String, int)> _specs = [
    ('Mango Verde', 'Easy', 7),
    ('Semilla Tierna', 'Easy', 8),
    ('Brote Nuevo', 'Easy', 8),
    ('Hoja Fresca', 'Easy', 9),
    ('Sol Naciente', 'Easy', 9),
    ('Pulpa Dulce', 'Medium', 11),
    ('Néctar Maduro', 'Medium', 12),
    ('Cosecha Media', 'Medium', 12),
    ('Fibra Jugosa', 'Medium', 13),
    ('Aroma Tropical', 'Medium', 13),
    ('Piel Dorada', 'Hard', 15),
    ('Hueso Duro', 'Hard', 16),
    ('Corazón del Mango', 'Hard', 16),
    ('Huerto Salvaje', 'Hard', 17),
    ('Rey Mango', 'Hard', 18),
  ];

  static final List<LevelModel> allLevels = [
    for (var i = 0; i < _specs.length; i++)
      LevelGenerator.generate(
        id: i + 1,
        name: _specs[i].$1,
        difficulty: _specs[i].$2,
        arrowCount: _specs[i].$3,
        seed: (i + 1) * 1000 + 7,
      ),
  ];

  static List<LevelModel> get easyLevels =>
      allLevels.where((l) => l.difficulty == 'Easy').toList();

  static List<LevelModel> get mediumLevels =>
      allLevels.where((l) => l.difficulty == 'Medium').toList();

  static List<LevelModel> get hardLevels =>
      allLevels.where((l) => l.difficulty == 'Hard').toList();

  static LevelModel? getById(int id) {
    for (final level in allLevels) {
      if (level.id == id) return level;
    }
    return null;
  }
}
