import 'package:arrowconmango_front/core/aop/aop_leaderboard_repository.dart';
import 'package:arrowconmango_front/features/leaderboard/domain/i_leaderboard_repository.dart';
import 'package:arrowconmango_front/features/leaderboard/domain/leaderboard_entry.dart';
import 'package:arrowconmango_front/features/player/domain/guest_player.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLeaderboardRepository extends Mock implements ILeaderboardRepository {}

void main() {
  group('AopLeaderboardRepository', () {
    late _MockLeaderboardRepository delegate;
    late AopLeaderboardRepository repository;

    setUp(() {
      delegate = _MockLeaderboardRepository();
      repository = AopLeaderboardRepository(delegate);
    });

    test('fetchTopPlayers forwards delegate result', () async {
      final player = GuestPlayer(uuid: 'u1', displayName: 'Player');
      final entries = [
        LeaderboardEntry(
          rank: 1,
          uuid: 'u1',
          displayName: 'Top',
          mangos: 100,
          colorValue: 0xFFFFFFFF,
        ),
      ];
      when(() => delegate.fetchTopPlayers(currentPlayer: player, limit: 10))
          .thenAnswer((_) async => entries);

      final result = await repository.fetchTopPlayers(
        currentPlayer: player,
        limit: 10,
      );

      expect(result, equals(entries));
      verify(() => delegate.fetchTopPlayers(currentPlayer: player, limit: 10))
          .called(1);
    });

    test('fetchTopPlayers rethrows non-Result exceptions after logging', () async {
      final player = GuestPlayer(uuid: 'u1', displayName: 'Player');
      when(() => delegate.fetchTopPlayers(currentPlayer: player))
          .thenThrow(Exception('network down'));

      expect(
        () => repository.fetchTopPlayers(currentPlayer: player),
        throwsA(isA<Exception>()),
      );
    });
  });
}
