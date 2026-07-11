import '../../player/domain/guest_player.dart';
import 'leaderboard_entry.dart';

/// Port for fetching the global leaderboard.
///
/// Implementations return the ranking with [currentPlayer] merged in and
/// flagged, so the UI can highlight the local guest. Backed by mock data for
/// now; a real backend (`GET /leaderboard`) can implement the same interface.
abstract interface class ILeaderboardRepository {
  Future<List<LeaderboardEntry>> fetchTopPlayers({
    required GuestPlayer currentPlayer,
    int limit = 20,
  });
}
