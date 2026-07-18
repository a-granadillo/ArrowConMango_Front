import '../../domain/entities/level.dart';
import 'cube_level_generator.dart';

/// Catalogue of deterministic "Tap Away"-style cube levels, plus a factory
/// for fresh randomized ones (restart/next). Ids are negative to mirror the
/// endless-mode convention elsewhere in the app: generated, not persisted.
abstract final class CubeLevels {
  static final Level small = CubeLevelGenerator.generate(
    id: -9001,
    name: 'Cubo Pequeño',
    config: const CubeLevelConfig(width: 3, height: 3, depth: 3, fillRatio: 0.60),
    seed: 90101,
  );

  static final Level medium = CubeLevelGenerator.generate(
    id: -9002,
    name: 'Cubo Mediano',
    config: const CubeLevelConfig(width: 4, height: 4, depth: 4, fillRatio: 0.60),
    seed: 90201,
  );

  static final Level large = CubeLevelGenerator.generate(
    id: -9003,
    name: 'Cubo Grande',
    config: const CubeLevelConfig(width: 5, height: 5, depth: 4, fillRatio: 0.55),
    seed: 90301,
  );

  static final List<Level> all = [small, medium, large];

  static const CubeLevelConfig _defaultFreshConfig = CubeLevelConfig(
    width: 4,
    height: 4,
    depth: 4,
    fillRatio: 0.60,
  );

  /// Generates a fresh cube level for "reintentar"/"siguiente" flows.
  static Level generateFresh(int seed, {CubeLevelConfig? config}) {
    return CubeLevelGenerator.generate(
      id: -(9000 + (seed.abs() % 9000)),
      name: 'Cubo Aleatorio',
      config: config ?? _defaultFreshConfig,
      seed: seed,
    );
  }
}
