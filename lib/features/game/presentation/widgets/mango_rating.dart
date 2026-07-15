import '../../../../l10n/app_localizations.dart';

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

  factory MangoRating.fromScore(int totalPoints, AppLocalizations l10n) {
    if (totalPoints >= 700) {
      return MangoRating._(3, l10n.ratingPerfect);
    }
    if (totalPoints >= 400) {
      return MangoRating._(2, l10n.ratingGreat);
    }
    return MangoRating._(1, l10n.ratingPass);
  }
}
