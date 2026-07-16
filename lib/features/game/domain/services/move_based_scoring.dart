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
  /// Points deducted per mistake.
  final int mistakePenalty;

  /// Minimum guaranteed points (floor).
  final int minPoints;

  const MoveBasedScoring({
    this.basePoints = 1000,
    this.movePenalty = 0,
    this.timePenalty = 10,
    this.mistakePenalty = 150,
    this.minPoints = 100,
  });

  @override
  Score calculateScore(int moves, int seconds, {int mistakes = 0}) {
    final moveDeduction = moves * movePenalty;
    final timeDeduction = seconds * timePenalty;
    final mistakeDeduction = mistakes * mistakePenalty;
    final raw = basePoints - moveDeduction - timeDeduction - mistakeDeduction;
    final total = raw < minPoints ? minPoints : raw;

    return Score(
      moves: moves,
      timeElapsed: seconds,
      totalPoints: total,
    );
  }
}
