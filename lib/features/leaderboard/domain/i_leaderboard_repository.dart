import 'leaderboard_entry.dart';

/// Port for fetching a level's own leaderboard or the survival leaderboard.
///
/// Both return top N plus the requesting player's own row (with their real
/// rank, even if outside the top) — see [LeaderboardPage].
abstract interface class ILeaderboardRepository {
  Future<LeaderboardPage> fetchByLevel({
    required String levelId,
    int top = 10,
  });

  Future<LeaderboardPage> fetchSurvival({int top = 10});
}
