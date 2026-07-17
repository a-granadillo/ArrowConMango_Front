/// Centralised route paths so screens don't hardcode strings.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String authGate = '/auth';
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String menu = '/menu';
  static const String playHub = '/play';
  static const String levels = '/levels';
  static const String settings = '/settings';
  static const String ranking = '/ranking';
  static const String game3d = '/game3d';

  /// Game route template; use [gameFor] to build a concrete path.
  static const String game = '/game/:levelId';
  static const String victory = '/victory';
  static const String defeat = '/defeat';

  /// Concrete game path for a given level id.
  static String gameFor(int levelId) => '/game/$levelId';

  // ── Modo Creativo ─────────────────────────────────────────────────────
  static const String creativeHub = '/creative';
  static const String creativeEditor = '/creative/editor';
  static const String creativeMine = '/creative/mine';
  static const String creativeCommunity = '/creative/community';
  static const String creativeRanking = '/creative/ranking';
}
