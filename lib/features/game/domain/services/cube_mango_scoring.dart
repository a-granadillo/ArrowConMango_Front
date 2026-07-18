import '../entities/score.dart';

/// Computes the mango reward for a finished cube round from raw metrics.
///
/// Formula: `basePoints - (moves × movePenalty) - (seconds × timePenalty) -
/// (mistakes × mistakePenalty)`, floored at [minPoints].
///
/// Mistakes (blocked taps) are penalized far more heavily than a normal move
/// since the player spent one of a limited budget without making progress.
/// [maxMistakes] is enforced by [Cube3DGameCubit] (the round ends in defeat
/// once reached), so a completed/victorious round only ever has
/// `0..maxMistakes-1` mistakes.
abstract final class CubeMangoScoring {
  static const int maxMistakes = 3;

  static const int basePoints = 800;
  static const int movePenalty = 20;
  static const int timePenalty = 5;
  static const int mistakePenalty = 120;
  static const int minPoints = 50;

  static Score calculate({
    required int moves,
    required int seconds,
    required int mistakes,
  }) {
    final deduction =
        moves * movePenalty + seconds * timePenalty + mistakes * mistakePenalty;
    final raw = basePoints - deduction;
    final total = raw < minPoints ? minPoints : raw;

    return Score(moves: moves, timeElapsed: seconds, totalPoints: total);
  }
}
