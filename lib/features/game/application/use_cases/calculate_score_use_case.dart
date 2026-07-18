import 'package:arrowconmango_front/features/game/domain/entities/score.dart';
import 'package:arrowconmango_front/features/game/domain/entities/scoring_strategy.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:injectable/injectable.dart';

/// Calculates a [Score] from raw game metrics using a [ScoringStrategy].
///
/// Validates that both inputs are non-negative before delegating to the
/// strategy. Any unexpected exception thrown by the strategy is captured
/// and returned as a [GenericFailure] wrapped in an [Error].
@lazySingleton
class CalculateScoreUseCase {
  final ScoringStrategy _scoringStrategy;

  const CalculateScoreUseCase(this._scoringStrategy);

  Result<Score> call({required int moves, required int elapsedSeconds, int mistakes = 0}) {
    if (moves < 0 || elapsedSeconds < 0) {
      return Error<Score>(
        GenericFailure('Moves and elapsed seconds must be non-negative'),
      );
    }

    try {
      final score = _scoringStrategy.calculateScore(moves, elapsedSeconds, mistakes: mistakes);
      return Success<Score>(score);
    } catch (e) {
      return Error<Score>(
        GenericFailure('Unhandled exception calculating score: $e'),
      );
    }
  }
}
