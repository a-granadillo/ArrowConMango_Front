import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:arrowconmango_front/features/game/domain/entities/score.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_state.dart';

/// Maps domain entities to presentation-layer [GameState] instances.
class GameStateMapper {
  GameStateMapper._();

  /// Maps an active [GameSession] into a [GamePlaying] state.
  static GamePlaying mapToPlayingState({
    required GameSession session,
    required Level level,
    required Score score,
    required int nowMs,
  }) {
    return GamePlaying(
      levelId: level.levelId,
      levelName: level.name,
      difficulty: level.difficulty(),
      rows: level.rows,
      cols: level.cols,
      boardState: session.boardState,
      moveCount: session.moveCount,
      history: session.history,
      score: score,
      arrowsRemaining: session.boardState.arrowCount,
      elapsedSeconds: session.elapsedSeconds(nowMs),
      startedAtMs: session.startedAtMs,
    );
  }

  /// Maps a victorious [GameSession] into a [GameVictory] state.
  static GameVictory mapToVictoryState({
    required GameSession session,
    required Level level,
    required Score score,
    required int nowMs,
  }) {
    return GameVictory(
      levelId: level.levelId,
      score: score,
      moveCount: session.moveCount,
      elapsedSeconds: session.elapsedSeconds(nowMs),
    );
  }

  /// Maps a defeated [GameSession] into a [GameDefeat] state.
  static GameDefeat mapToDefeatState({
    required GameSession session,
    required Level level,
    required DefeatReason reason,
    required int nowMs,
  }) {
    return GameDefeat(
      levelId: level.levelId,
      reason: reason,
      moveCount: session.moveCount,
      elapsedSeconds: session.elapsedSeconds(nowMs),
    );
  }
}
