import 'score.dart';
import 'scoring_strategy.dart';

/// Scoring that primarily rewards speed.
///
/// Formula: base points decrease as time increases, with a small penalty
/// per move.  For example: `max(1000 - seconds * 2 - moves * 5, 0)`.
class TimeBasedScoring implements ScoringStrategy {
  /// Base points awarded before penalties.
  static const int basePoints = 1000;

  /// Points deducted per second elapsed.
  static const int timePenaltyPerSecond = 2;

  /// Points deducted per move.
  static const int movePenalty = 5;

  const TimeBasedScoring();

  @override
  Score calculateScore(int moves, int seconds) {
    final raw = basePoints - (seconds * timePenaltyPerSecond) - (moves * movePenalty);
    final points = raw < 0 ? 0 : raw;
    return Score(moves: moves, timeElapsed: seconds, totalPoints: points);
  }
}
