import 'package:arrowconmango_front/features/game/application/dtos/game_evaluation.dart';
import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/entities/scoring_strategy.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/score.dart';

@lazySingleton
class EvaluateGameStateUseCase {
  final ScoringStrategy _scoringStrategy;

  const EvaluateGameStateUseCase(this._scoringStrategy);

  GameEvaluation call({required GameSession session, required int nowMs}) {
    final bool isVictory = session.isVictory;
    final GameStatus status =
        isVictory ? GameStatus.victory : GameStatus.ongoing;

    final int elapsed = session.elapsedSeconds(nowMs);
    final Score score = _scoringStrategy.calculateScore(
      session.moveCount,
      elapsed,
      mistakes: session.mistakes,
    );
    final int arrowsRemaining = session.boardState.arrowCount;

    return GameEvaluation(
      status: status,
      score: score,
      moveCount: session.moveCount,
      elapsedSeconds: elapsed,
      arrowsRemaining: arrowsRemaining,
    );
  }
}