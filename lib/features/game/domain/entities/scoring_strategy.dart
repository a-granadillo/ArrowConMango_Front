import 'score.dart';

/// Strategy interface for computing a [Score] from raw game metrics.
///
/// Allows the scoring algorithm to vary independently from
/// [EvaluateGameStateUseCase] (Strategy pattern / OCP).
abstract class ScoringStrategy {
  /// Produces a [Score] based on the number of [moves] and elapsed [seconds].
  Score calculateScore(int moves, int seconds);
}
