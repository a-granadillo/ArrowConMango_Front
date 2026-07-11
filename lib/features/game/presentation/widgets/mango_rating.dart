/// Maps a level's final score to the design's 1–3 mango performance rating
/// and celebration message.
///
/// The design computes its rating from remaining/idle arrows, a concept our
/// domain doesn't expose to the presentation layer at victory time; this
/// derives an equivalent rating from [Score.totalPoints] (itself already a
/// moves/time efficiency metric) using tertile-like thresholds.
class MangoRating {
  const MangoRating._(this.stars, this.message);

  /// 1 (pass), 2 (great) or 3 (perfect) mangos earned.
  final int stars;

  /// Celebration message matching the design's copy for this tier.
  final String message;

  factory MangoRating.fromScore(int totalPoints) {
    if (totalPoints >= 700) {
      return const MangoRating._(
        3,
        '¡Cosecha perfecta! Eres un maestro del mango',
      );
    }
    if (totalPoints >= 400) {
      return const MangoRating._(2, '¡Muy bien! Casi una cosecha perfecta');
    }
    return const MangoRating._(
      1,
      '¡Nivel superado! Sé más rápido y preciso para más mangos',
    );
  }
}
