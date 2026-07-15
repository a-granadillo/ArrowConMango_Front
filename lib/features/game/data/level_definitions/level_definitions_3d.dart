import '../../domain/entities/level.dart';

import 'level_generator_3d.dart';

/// The game's 3D level catalogue (issue #43 — domain-only, levels 16-25).
///
/// This is a **lazy** catalogue: [campaignLevels3D] is a `static final` list,
/// so the ten [Level] entities are only generated the first time the getter
/// is accessed (e.g. from a future 3D game mode or from tests) — never from
/// `main()`/`setupServiceLocator`, so it has no impact on app startup time.
///
/// Levels 16-20 are small introductory volumes; 21-25 raise the arrow count,
/// bend ratios and target blocking-graph depth.
class LevelDefinitions3D {
  LevelDefinitions3D._();

  static final List<Level> campaignLevels3D = [
    // --- INTRODUCTORY 3D LEVELS (small volumes, gentle depth targets) ---
    LevelGenerator3D.generate(
      id: 16,
      name: 'Mango Cúbico',
      config: const LevelConfig3D(
        width: 5,
        height: 5,
        depth: 3,
        arrowCount: 8,
        straightRatio: 0.60,
        lShapeRatio: 0.40,
        zShapeRatio: 0.0,
        minSegmentLength: 1,
        maxSegmentLength: 2,
        minGraphDepth: 2,
      ),
      seed: 16101,
    ),
    LevelGenerator3D.generate(
      id: 17,
      name: 'Capa Interior',
      config: const LevelConfig3D(
        width: 5,
        height: 5,
        depth: 3,
        arrowCount: 10,
        straightRatio: 0.50,
        lShapeRatio: 0.50,
        zShapeRatio: 0.0,
        minSegmentLength: 1,
        maxSegmentLength: 2,
        minGraphDepth: 2,
      ),
      seed: 17101,
    ),
    LevelGenerator3D.generate(
      id: 18,
      name: 'Profundidad Verde',
      config: const LevelConfig3D(
        width: 5,
        height: 6,
        depth: 3,
        arrowCount: 10,
        straightRatio: 0.40,
        lShapeRatio: 0.40,
        zShapeRatio: 0.20,
        minSegmentLength: 1,
        maxSegmentLength: 2,
        minGraphDepth: 3,
      ),
      seed: 18101,
    ),
    LevelGenerator3D.generate(
      id: 19,
      name: 'Eje Z Naciente',
      config: const LevelConfig3D(
        width: 6,
        height: 6,
        depth: 3,
        arrowCount: 12,
        straightRatio: 0.35,
        lShapeRatio: 0.40,
        zShapeRatio: 0.25,
        minSegmentLength: 1,
        maxSegmentLength: 2,
        minGraphDepth: 3,
      ),
      seed: 19101,
    ),
    LevelGenerator3D.generate(
      id: 20,
      name: 'Volumen Maduro',
      config: const LevelConfig3D(
        width: 6,
        height: 6,
        depth: 4,
        arrowCount: 14,
        straightRatio: 0.30,
        lShapeRatio: 0.40,
        zShapeRatio: 0.30,
        minSegmentLength: 1,
        maxSegmentLength: 3,
        minGraphDepth: 3,
      ),
      seed: 20101,
    ),

    // --- ADVANCED 3D LEVELS (larger volumes, higher depth targets) ---
    LevelGenerator3D.generate(
      id: 21,
      name: 'Cubo Dorado',
      config: const LevelConfig3D(
        width: 6,
        height: 6,
        depth: 4,
        arrowCount: 16,
        straightRatio: 0.25,
        lShapeRatio: 0.40,
        zShapeRatio: 0.35,
        minSegmentLength: 1,
        maxSegmentLength: 3,
        minGraphDepth: 4,
        switchableRatio: 0.10,
      ),
      seed: 21101,
    ),
    LevelGenerator3D.generate(
      id: 22,
      name: 'Prisma Salvaje',
      config: const LevelConfig3D(
        width: 7,
        height: 6,
        depth: 4,
        arrowCount: 18,
        straightRatio: 0.20,
        lShapeRatio: 0.40,
        zShapeRatio: 0.40,
        minSegmentLength: 1,
        maxSegmentLength: 3,
        minGraphDepth: 4,
        switchableRatio: 0.15,
      ),
      seed: 22101,
    ),
    LevelGenerator3D.generate(
      id: 23,
      name: 'Núcleo Tridimensional',
      config: const LevelConfig3D(
        width: 7,
        height: 7,
        depth: 4,
        arrowCount: 20,
        straightRatio: 0.20,
        lShapeRatio: 0.35,
        zShapeRatio: 0.45,
        minSegmentLength: 1,
        maxSegmentLength: 3,
        minGraphDepth: 5,
        switchableRatio: 0.15,
      ),
      seed: 23101,
    ),
    LevelGenerator3D.generate(
      id: 24,
      name: 'Laberinto Z',
      config: const LevelConfig3D(
        width: 7,
        height: 7,
        depth: 5,
        arrowCount: 22,
        straightRatio: 0.15,
        lShapeRatio: 0.35,
        zShapeRatio: 0.50,
        minSegmentLength: 1,
        maxSegmentLength: 3,
        minGraphDepth: 5,
        switchableRatio: 0.20,
      ),
      seed: 24101,
    ),
    LevelGenerator3D.generate(
      id: 25,
      name: 'Rey del Cubo',
      config: const LevelConfig3D(
        width: 7,
        height: 7,
        depth: 5,
        arrowCount: 24,
        straightRatio: 0.15,
        lShapeRatio: 0.30,
        zShapeRatio: 0.55,
        minSegmentLength: 2,
        maxSegmentLength: 3,
        minGraphDepth: 6,
        switchableRatio: 0.20,
      ),
      seed: 25101,
    ),
  ];

  static Level? getById(int id) {
    for (final level in campaignLevels3D) {
      if (level.levelId == id) return level;
    }
    return null;
  }
}
