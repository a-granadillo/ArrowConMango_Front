/// Centralised route paths so screens don't hardcode strings.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String menu = '/menu';
  static const String levels = '/levels';
  static const String settings = '/settings';
  static const String ranking = '/ranking';

  /// Game route template; use [gameFor] to build a concrete path.
  static const String game = '/game/:levelId';
  static const String victory = '/victory';
  static const String defeat = '/defeat';

  /// Concrete game path for a given level id.
  static String gameFor(int levelId) => '/game/$levelId';
}
