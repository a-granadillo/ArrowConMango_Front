import 'package:arrowconmango_front/features/leaderboard/domain/i_leaderboard_repository.dart';
import 'package:arrowconmango_front/features/leaderboard/domain/leaderboard_entry.dart';

import 'aop_invoker.dart';

/// AOP decorator around [ILeaderboardRepository].
///
/// Adds centralized logging. Infrastructure exceptions are logged and
/// rethrown so callers receive the same failure surface they would see
/// without AOP.
class AopLeaderboardRepository implements ILeaderboardRepository {
  const AopLeaderboardRepository(this._delegate);

  final ILeaderboardRepository _delegate;

  @override
  Future<LeaderboardPage> fetchByLevel({
    required String levelId,
    int top = 10,
  }) =>
      AopInvoker.invoke(
        'ILeaderboardRepository',
        'fetchByLevel',
        () => _delegate.fetchByLevel(levelId: levelId, top: top),
      );

  @override
  Future<LeaderboardPage> fetchSurvival({int top = 10}) => AopInvoker.invoke(
        'ILeaderboardRepository',
        'fetchSurvival',
        () => _delegate.fetchSurvival(top: top),
      );
}
