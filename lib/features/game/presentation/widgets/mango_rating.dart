import '../../../../l10n/app_localizations.dart';
import '../../domain/services/mango_stars.dart';

/// Maps a level's final score to the design's 1–3 mango performance rating
/// and celebration message.
///
/// The design computes its rating from remaining/idle arrows, a concept our
/// domain doesn't expose to the presentation layer at victory time; this
/// derives an equivalent rating from [Score.totalPoints] (itself already a
/// moves/time efficiency metric) using [MangoStars]'s tertile thresholds.
class MangoRating {
  const MangoRating._(this.stars, this.message);

  /// 1 (pass), 2 (great) or 3 (perfect) mangos earned.
  final int stars;

  /// Celebration message matching the design's copy for this tier.
  final String message;

  factory MangoRating.fromScore(int totalPoints, AppLocalizations l10n) {
    final stars = MangoStars.fromPoints(totalPoints);
    final message = switch (stars) {
      3 => l10n.ratingPerfect,
      2 => l10n.ratingGreat,
      _ => l10n.ratingPass,
    };
    return MangoRating._(stars, message);
  }
}
