import 'package:arrowconmango_front/features/leaderboard/domain/i_leaderboard_repository.dart';
import 'package:arrowconmango_front/features/leaderboard/domain/leaderboard_entry.dart';
import 'package:arrowconmango_front/features/player/domain/guest_player.dart';

import 'aop_invoker.dart';

/// AOP decorator around [ILeaderboardRepository].
///
/// Adds centralized logging. Because [fetchTopPlayers] does not return a
/// [Result], infrastructure exceptions are logged and rethrown so callers
/// receive the same failure surface they would see without AOP.
class AopLeaderboardRepository implements ILeaderboardRepository {
  const AopLeaderboardRepository(this._delegate);

  final ILeaderboardRepository _delegate;

  @override
  Future<List<LeaderboardEntry>> fetchTopPlayers({
    required GuestPlayer currentPlayer,
    int limit = 20,
  }) =>
      AopInvoker.invoke(
        'ILeaderboardRepository',
        'fetchTopPlayers',
        () => _delegate.fetchTopPlayers(
          currentPlayer: currentPlayer,
          limit: limit,
        ),
      );
}
