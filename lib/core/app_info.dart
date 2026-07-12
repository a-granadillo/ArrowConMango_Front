import '../features/game/data/level_definitions/level_definitions.dart';

/// App-wide constants derived from the content catalogue.
abstract final class AppInfo {
  /// Total number of playable levels.
  static int get totalLevels => LevelDefinitions.allLevels.length;
}
