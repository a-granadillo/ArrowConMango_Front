import 'package:arrowconmango_front/features/game/data/models/level_model.dart';

import 'level_generator.dart';
import 'silhouettes.dart';

/// The game's level catalogues (Campaign and Endless).
///
/// - `campaignLevels`: 15 procedurally generated levels (guaranteed solvable).
/// - `generateEndless()`: Dynamic levels for endless mode.
class LevelDefinitions {
  LevelDefinitions._();

  /// The 15 campaign levels mapped to their specific structural configurations and visual silhouettes.
  static final List<LevelModel> campaignLevels = [
    // --- EASY LEVELS (mostly 6x6, straight and L-shapes, ~15 arrows) ---
    LevelGenerator.generate(
      id: 1,
      name: 'Mango Verde',
      difficulty: 'Easy',
      config: const LevelConfig(
        rows: 6,
        cols: 7,
        arrowCount: 12,
        straightRatio: 0.60,
        lShapeRatio: 0.40,
        zShapeRatio: 0.0,
        uShapeRatio: 0.0,
        minSegmentLength: 2,
        maxSegmentLength: 4,
        minGraphDepth: 3,
        silhouette: Silhouettes.heart, // Shape of Heart
      ),
      seed: 1007,
    ),
    LevelGenerator.generate(
      id: 2,
      name: 'Semilla Tierna',
      difficulty: 'Easy',
      config: const LevelConfig(
        rows: 7,
        cols: 7,
        arrowCount: 15,
        straightRatio: 0.60,
        lShapeRatio: 0.40,
        zShapeRatio: 0.0,
        uShapeRatio: 0.0,
        minSegmentLength: 2,
        maxSegmentLength: 4,
        minGraphDepth: 3,
        silhouette: Silhouettes.star, // Shape of Star
      ),
      seed: 2007,
    ),
    LevelGenerator.generate(
      id: 3,
      name: 'Brote Nuevo',
      difficulty: 'Easy',
      config: const LevelConfig(
        rows: 7,
        cols: 7,
        arrowCount: 15,
        straightRatio: 0.60,
        lShapeRatio: 0.40,
        zShapeRatio: 0.0,
        uShapeRatio: 0.0,
        minSegmentLength: 2,
        maxSegmentLength: 4,
        minGraphDepth: 3,
        silhouette: Silhouettes.arrowUp, // Shape of Arrow Up
      ),
      seed: 3007,
    ),
    LevelGenerator.generate(
      id: 4,
      name: 'Hoja Fresca',
      difficulty: 'Easy',
      config: const LevelConfig(
        rows: 7,
        cols: 7,
        arrowCount: 16,
        straightRatio: 0.60,
        lShapeRatio: 0.40,
        zShapeRatio: 0.0,
        uShapeRatio: 0.0,
        minSegmentLength: 2,
        maxSegmentLength: 4,
        minGraphDepth: 3,
        silhouette: Silhouettes.house, // Shape of House
      ),
      seed: 4007,
    ),
    LevelGenerator.generate(
      id: 5,
      name: 'Sol Naciente',
      difficulty: 'Easy',
      config: const LevelConfig(
        rows: 7,
        cols: 7,
        arrowCount: 12,
        straightRatio: 0.60,
        lShapeRatio: 0.40,
        zShapeRatio: 0.0,
        uShapeRatio: 0.0,
        minSegmentLength: 2,
        maxSegmentLength: 4,
        minGraphDepth: 3,
        silhouette: Silhouettes.diamond, // Shape of Diamond
      ),
      seed: 5007,
    ),

    // --- MEDIUM LEVELS (mostly 8x8, mix of shapes, ~25-30 arrows) ---
    LevelGenerator.generate(
      id: 6,
      name: 'Pulpa Dulce',
      difficulty: 'Medium',
      config: const LevelConfig(
        rows: 9,
        cols: 9,
        arrowCount: 20,
        straightRatio: 0.30,
        lShapeRatio: 0.35,
        zShapeRatio: 0.20,
        uShapeRatio: 0.15,
        minSegmentLength: 2,
        maxSegmentLength: 4,
        minGraphDepth: 5,
        silhouette: Silhouettes.mango, // Shape of Mango
      ),
      seed: 6007,
    ),
    LevelGenerator.generate(
      id: 7,
      name: 'Néctar Maduro',
      difficulty: 'Medium',
      config: const LevelConfig(
        rows: 9,
        cols: 9,
        arrowCount: 22,
        straightRatio: 0.30,
        lShapeRatio: 0.35,
        zShapeRatio: 0.20,
        uShapeRatio: 0.15,
        minSegmentLength: 2,
        maxSegmentLength: 4,
        minGraphDepth: 5,
        silhouette: Silhouettes.car, // Shape of Car
      ),
      seed: 7007,
    ),
    LevelGenerator.generate(
      id: 8,
      name: 'Cosecha Media',
      difficulty: 'Medium',
      config: const LevelConfig(
        rows: 9,
        cols: 9,
        arrowCount: 20,
        straightRatio: 0.30,
        lShapeRatio: 0.35,
        zShapeRatio: 0.20,
        uShapeRatio: 0.15,
        minSegmentLength: 2,
        maxSegmentLength: 4,
        minGraphDepth: 5,
        silhouette: Silhouettes.spaceship, // Shape of Spaceship
      ),
      seed: 8007,
    ),
    LevelGenerator.generate(
      id: 9,
      name: 'Fibra Jugosa',
      difficulty: 'Medium',
      config: const LevelConfig(
        rows: 9,
        cols: 9,
        arrowCount: 20,
        straightRatio: 0.30,
        lShapeRatio: 0.35,
        zShapeRatio: 0.20,
        uShapeRatio: 0.15,
        minSegmentLength: 2,
        maxSegmentLength: 4,
        minGraphDepth: 5,
        silhouette: Silhouettes.tree, // Shape of Tree
      ),
      seed: 9007,
    ),
    LevelGenerator.generate(
      id: 10,
      name: 'Aroma Tropical',
      difficulty: 'Medium',
      config: const LevelConfig(
        rows: 9,
        cols: 9,
        arrowCount: 25,
        straightRatio: 0.30,
        lShapeRatio: 0.35,
        zShapeRatio: 0.20,
        uShapeRatio: 0.15,
        minSegmentLength: 2,
        maxSegmentLength: 4,
        minGraphDepth: 5,
        silhouette: Silhouettes.butterfly, // Shape of Butterfly
      ),
      seed: 10007,
    ),

    // --- HARD LEVELS (mostly 12x12, full complexity, +40 arrows) ---
    LevelGenerator.generate(
      id: 11,
      name: 'Piel Dorada',
      difficulty: 'Hard',
      config: const LevelConfig(
        rows: 12,
        cols: 12,
        arrowCount: 38,
        straightRatio: 0.15,
        lShapeRatio: 0.35,
        zShapeRatio: 0.30,
        uShapeRatio: 0.20,
        minSegmentLength: 2,
        maxSegmentLength: 5,
        minGraphDepth: 8,
        silhouette: Silhouettes.dragon, // Shape of Dragon
      ),
      seed: 11007,
    ),
    LevelGenerator.generate(
      id: 12,
      name: 'Hueso Duro',
      difficulty: 'Hard',
      config: const LevelConfig(
        rows: 12,
        cols: 12,
        arrowCount: 40,
        straightRatio: 0.15,
        lShapeRatio: 0.35,
        zShapeRatio: 0.30,
        uShapeRatio: 0.20,
        minSegmentLength: 2,
        maxSegmentLength: 5,
        minGraphDepth: 8,
        silhouette: Silhouettes.castle, // Shape of Castle
      ),
      seed: 12007,
    ),
    LevelGenerator.generate(
      id: 13,
      name: 'Corazón del Mango',
      difficulty: 'Hard',
      config: const LevelConfig(
        rows: 11,
        cols: 10,
        arrowCount: 35,
        straightRatio: 0.15,
        lShapeRatio: 0.35,
        zShapeRatio: 0.30,
        uShapeRatio: 0.20,
        minSegmentLength: 2,
        maxSegmentLength: 5,
        minGraphDepth: 8,
        silhouette: Silhouettes.robot, // Shape of Robot
      ),
      seed: 13007,
    ),
    LevelGenerator.generate(
      id: 14,
      name: 'Huerto Salvaje',
      difficulty: 'Hard',
      config: const LevelConfig(
        rows: 12,
        cols: 12,
        arrowCount: 42,
        straightRatio: 0.15,
        lShapeRatio: 0.35,
        zShapeRatio: 0.30,
        uShapeRatio: 0.20,
        minSegmentLength: 2,
        maxSegmentLength: 5,
        minGraphDepth: 8,
        silhouette: Silhouettes.phoenix, // Shape of Phoenix
      ),
      seed: 14007,
    ),
    LevelGenerator.generate(
      id: 15,
      name: 'Rey Mango',
      difficulty: 'Hard',
      config: const LevelConfig(
        rows: 12,
        cols: 12,
        arrowCount: 50,
        straightRatio: 0.15,
        lShapeRatio: 0.35,
        zShapeRatio: 0.30,
        uShapeRatio: 0.20,
        minSegmentLength: 2,
        maxSegmentLength: 5,
        minGraphDepth: 8,
        silhouette: Silhouettes.geometricPattern, // Shape of Geometric Pattern
      ),
      seed: 15007,
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
