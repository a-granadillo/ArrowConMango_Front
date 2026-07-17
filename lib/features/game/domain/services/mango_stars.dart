/// Pure 1–3 star tertile mapping from a computed score's total points.
///
/// Mirrors the design's mango-rating thresholds. Kept framework/UI-free
/// (no [AppLocalizations] dependency) so both the application-layer level
/// list use case and the presentation-layer victory rating widget can share
/// the same thresholds without the application layer reaching into
/// presentation.
abstract final class MangoStars {
  static int fromPoints(int totalPoints) {
    if (totalPoints >= 900) return 3;
    if (totalPoints >= 600) return 2;
    return 1;
  }
}
