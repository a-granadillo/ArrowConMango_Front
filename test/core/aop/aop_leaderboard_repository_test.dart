import 'package:arrowconmango_front/core/aop/aop_leaderboard_repository.dart';
import 'package:arrowconmango_front/features/leaderboard/domain/i_leaderboard_repository.dart';
import 'package:arrowconmango_front/features/leaderboard/domain/leaderboard_entry.dart';
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

    test('fetchByLevel forwards delegate result', () async {
      final page = LeaderboardPage(
        top: const [
          LeaderboardEntry(
            rank: 1,
            uuid: 'u1',
            displayName: 'Top',
            mangos: 900,
            colorValue: 0xFFFFFFFF,
          ),
        ],
        me: null,
      );
      when(() => delegate.fetchByLevel(levelId: '1', top: 10))
          .thenAnswer((_) async => page);

      final result = await repository.fetchByLevel(levelId: '1');

      expect(result, equals(page));
      verify(() => delegate.fetchByLevel(levelId: '1', top: 10)).called(1);
    });

    test('fetchByLevel rethrows non-Result exceptions after logging', () async {
      when(() => delegate.fetchByLevel(levelId: '1', top: 10))
          .thenThrow(Exception('network down'));

      expect(
        () => repository.fetchByLevel(levelId: '1'),
        throwsA(isA<Exception>()),
      );
    });

    test('fetchSurvival forwards delegate result', () async {
      const page = LeaderboardPage(top: [], me: null);
      when(() => delegate.fetchSurvival(top: 10)).thenAnswer((_) async => page);

      final result = await repository.fetchSurvival();

      expect(result, equals(page));
      verify(() => delegate.fetchSurvival(top: 10)).called(1);
    });
  });
}
