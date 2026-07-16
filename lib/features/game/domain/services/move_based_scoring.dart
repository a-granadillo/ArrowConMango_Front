import '../entities/score.dart';
import '../entities/scoring_strategy.dart';

/// Concrete scoring algorithm that penalizes moves and time.
///
/// Formula:
///   basePoints - (moves × movePenalty) - (seconds × timePenalty)
///
/// Ensures a minimum of [minPoints] to avoid zero or negative scores.
class MoveBasedScoring implements ScoringStrategy {
  /// Starting points before penalties.
  final int basePoints;

  /// Points deducted per move.
  final int movePenalty;

  /// Points deducted per second.
  final int timePenalty;

  /// Minimum guaranteed points (floor).
  final int minPoints;

  const MoveBasedScoring({
    this.basePoints = 1000,
    this.movePenalty = 50,
    this.timePenalty = 10,
    this.minPoints = 100,
  });

  @override
  Score calculateScore(int moves, int seconds) {
    final moveDeduction = moves * movePenalty;
    final timeDeduction = seconds * timePenalty;
    final raw = basePoints - moveDeduction - timeDeduction;
    final total = raw < minPoints ? minPoints : raw;

    return Score(
      moves: moves,
      timeElapsed: seconds,
      totalPoints: total,
    );
  }
}
