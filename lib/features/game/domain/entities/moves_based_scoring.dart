import 'score.dart';
import 'scoring_strategy.dart';

/// Scoring that primarily rewards efficiency (fewer moves).
///
/// Formula: base points decrease as the move count increases, with a
/// small penalty for time.  For example:
/// `max(1000 - moves * 10 - seconds * 1, 0)`.
class MovesBasedScoring implements ScoringStrategy {
  /// Base points awarded before penalties.
  static const int basePoints = 1000;

  /// Points deducted per move.
  static const int movePenalty = 10;

  /// Points deducted per second elapsed.
  static const int timePenaltyPerSecond = 1;

  const MovesBasedScoring();

  @override
  Score calculateScore(int moves, int seconds) {
    final raw = basePoints - (moves * movePenalty) - (seconds * timePenaltyPerSecond);
    final points = raw < 0 ? 0 : raw;
    return Score(moves: moves, timeElapsed: seconds, totalPoints: points);
  }
}
