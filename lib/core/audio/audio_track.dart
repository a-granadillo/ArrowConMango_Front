/// Background music tracks used across the application.
enum AudioTrack {
  menuTheme,
  gameTheme,
  victoryTheme;

  /// Asset path expected by [AudioPlayer].
  ///
  /// [audioplayers] automatically resolves paths under `assets/`, so the
  /// leading `assets/` segment must be omitted.
  String get assetPath => switch (this) {
    AudioTrack.menuTheme => 'audio/music/menu_theme.mp3',
    AudioTrack.gameTheme => 'audio/music/game_theme.mp3',
    AudioTrack.victoryTheme => 'audio/music/victory_theme.mp3',
  };
}
