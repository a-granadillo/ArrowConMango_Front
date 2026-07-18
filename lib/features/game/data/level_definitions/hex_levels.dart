import '../../domain/entities/hex_level.dart';
import 'hex_level_generator.dart';

/// Local, offline-first catalogue of hexagonal-board levels of progressively
/// increasing difficulty (bigger board — radius 3 to 5 — denser fill, longer
/// and increasingly bent arrow bodies), used when the remote catalogue
/// (`GET /levels?shape=hex`) is unreachable — see [HexLevelRepository]. Ids
/// are prefixed `local-hex-` to stay visibly distinct from the backend's
/// `hex-###` ids.
abstract final class HexLevels {
  static final HexLevel level1 = HexLevelGenerator.generate(
    id: 'local-hex-001',
    name: 'Panal Verde',
    difficulty: 'Easy',
    config: const HexLevelConfig(radius: 3, fillRatio: 0.5, maxArrowLength: 2),
    seed: 70101,
  );

  static final HexLevel level2 = HexLevelGenerator.generate(
    id: 'local-hex-002',
    name: 'Panal Amarillo',
    difficulty: 'Easy',
    config: const HexLevelConfig(
      radius: 3,
      fillRatio: 0.6,
      maxArrowLength: 3,
      maxSegments: 2,
    ),
    seed: 70201,
  );

  static final HexLevel level3 = HexLevelGenerator.generate(
    id: 'local-hex-003',
    name: 'Colmena Naranja',
    difficulty: 'Medium',
    config: const HexLevelConfig(
      radius: 4,
      fillRatio: 0.55,
      maxArrowLength: 3,
      maxSegments: 2,
    ),
    seed: 70301,
  );

  static final HexLevel level4 = HexLevelGenerator.generate(
    id: 'local-hex-004',
    name: 'Colmena Roja',
    difficulty: 'Medium',
    config: const HexLevelConfig(
      radius: 4,
      fillRatio: 0.65,
      maxArrowLength: 4,
      maxSegments: 3,
    ),
    seed: 70401,
  );

  static final HexLevel level5 = HexLevelGenerator.generate(
    id: 'local-hex-005',
    name: 'Panal Mango',
    difficulty: 'Hard',
    config: const HexLevelConfig(
      radius: 5,
      fillRatio: 0.6,
      maxArrowLength: 4,
      maxSegments: 3,
    ),
    seed: 70501,
  );

  static final List<HexLevel> all = [level1, level2, level3, level4, level5];
}
