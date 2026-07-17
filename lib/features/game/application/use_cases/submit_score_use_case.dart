import 'package:arrowconmango_front/features/game/data/datasources/remote_leaderboard_data_source.dart';
import 'package:injectable/injectable.dart';

/// Submits a completed level's score to the backend leaderboard.
///
/// Best-effort: intended to be called fire-and-forget from ProgressBloc so
/// a network failure never blocks the victory flow, consistent with the
/// app's offline-first posture elsewhere (see SyncedProgressRepository).
/// Errors are swallowed here rather than at the call site, since there is no
/// meaningful UI recovery for a failed leaderboard submission — the score
/// still lives locally via the progress sync path.
@lazySingleton
class SubmitScoreUseCase {
  const SubmitScoreUseCase(this._remoteLeaderboardDataSource);

  final RemoteLeaderboardDataSource _remoteLeaderboardDataSource;

  Future<void> call({
    required int levelId,
    required int moves,
    required int elapsedSeconds,
  }) async {
    try {
      await _remoteLeaderboardDataSource.submit(
        levelId: levelId,
        moves: moves,
        elapsedSeconds: elapsedSeconds,
      );
    } catch (_) {
      // Best-effort: swallow. See class doc.
    }
  }
}
