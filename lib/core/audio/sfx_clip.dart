/// One-shot sound effects triggered from gameplay and UI interactions.
enum SfxClip {
  click,
  arrowExit,
  victory,
  defeat;

  /// Asset path expected by [AudioPlayer].
  ///
  /// [audioplayers] automatically resolves paths under `assets/`, so the
  /// leading `assets/` segment must be omitted.
  String get assetPath => switch (this) {
    SfxClip.click => 'audio/sfx/click.wav',
    SfxClip.arrowExit => 'audio/sfx/arrow_exit.wav',
    SfxClip.victory => 'audio/sfx/victory.wav',
    SfxClip.defeat => 'audio/sfx/defeat.wav',
  };
}
