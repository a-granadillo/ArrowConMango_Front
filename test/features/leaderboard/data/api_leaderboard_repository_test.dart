import 'package:arrowconmango_front/features/game/data/datasources/remote_leaderboard_data_source.dart';
import 'package:arrowconmango_front/features/leaderboard/data/api_leaderboard_repository.dart';
import 'package:arrowconmango_front/features/leaderboard/domain/leaderboard_entry.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockRemoteLeaderboardDataSource extends Mock
    implements RemoteLeaderboardDataSource {}

void main() {
  late _MockRemoteLeaderboardDataSource dataSource;
  late ApiLeaderboardRepository repository;

  setUp(() {
    dataSource = _MockRemoteLeaderboardDataSource();
    repository = ApiLeaderboardRepository(dataSource);
  });

  group('fetchByLevel', () {
    test('should_map_backend_rows_into_leaderboard_entries', () async {
      // Arrange
      when(() => dataSource.fetchByLevel('1', top: any(named: 'top')))
          .thenAnswer(
        (_) async => {
          'top': [
            {
              'rank': 1,
              'userId': 'u1',
              'displayName': 'MangoReina_88',
              'levelId': '1',
              'moves': 5,
              'timeMs': 12000,
              'value': 900,
              'at': '2026-01-01T00:00:00.000Z',
              'isMe': false,
            },
          ],
          'me': {
            'rank': 4,
            'userId': 'me',
            'displayName': 'MangoLoco_10',
            'levelId': '1',
            'moves': 8,
            'timeMs': 20000,
            'value': 600,
            'at': '2026-01-01T00:00:00.000Z',
            'isMe': true,
          },
        },
      );

      // Act
      final page = await repository.fetchByLevel(levelId: '1');

      // Assert
      expect(page.top, hasLength(1));
      expect(page.top[0].rank, 1);
      expect(page.top[0].uuid, 'u1');
      expect(page.top[0].displayName, 'MangoReina_88');
      expect(page.top[0].mangos, 900);
      expect(page.top[0].secondaryValue, 5);
      expect(page.top[0].metric, LeaderboardMetric.moves);
      expect(page.top[0].isCurrentPlayer, isFalse);
      expect(page.me, isNotNull);
      expect(page.me!.rank, 4);
      expect(page.me!.isCurrentPlayer, isTrue);
    });

    test('should_return_null_me_when_the_player_has_no_entry', () async {
      when(() => dataSource.fetchByLevel('1', top: any(named: 'top')))
          .thenAnswer((_) async => {'top': <dynamic>[], 'me': null});

      final page = await repository.fetchByLevel(levelId: '1');

      expect(page.top, isEmpty);
      expect(page.me, isNull);
    });

    test('should_derive_a_stable_colorValue_from_the_uuid', () async {
      when(() => dataSource.fetchByLevel('1', top: any(named: 'top')))
          .thenAnswer(
        (_) async => {
          'top': [
            {
              'rank': 1,
              'userId': 'stable-uuid',
              'displayName': 'Someone',
              'levelId': '1',
              'moves': 2,
              'timeMs': 1000,
              'value': 950,
              'at': '2026-01-01T00:00:00.000Z',
              'isMe': false,
            },
          ],
          'me': null,
        },
      );

      final first = await repository.fetchByLevel(levelId: '1');
      final second = await repository.fetchByLevel(levelId: '1');

      expect(first.top.single.colorValue, second.top.single.colorValue);
    });

    test('should_pass_the_requested_top_through_to_the_datasource', () async {
      when(() => dataSource.fetchByLevel('1', top: any(named: 'top')))
          .thenAnswer((_) async => {'top': <dynamic>[], 'me': null});

      await repository.fetchByLevel(levelId: '1', top: 5);

      verify(() => dataSource.fetchByLevel('1', top: 5)).called(1);
    });
  });

  group('fetchSurvival', () {
    test('should_map_backend_rows_into_leaderboard_entries', () async {
      when(() => dataSource.fetchSurvival(top: any(named: 'top'))).thenAnswer(
        (_) async => {
          'top': [
            {
              'rank': 1,
              'userId': 'u1',
              'displayName': 'SurvivalKing',
              'mangos': 24,
              'runs': 8,
              'isMe': false,
            },
          ],
          'me': null,
        },
      );

      final page = await repository.fetchSurvival();

      expect(page.top, hasLength(1));
      expect(page.top[0].mangos, 24);
      expect(page.top[0].secondaryValue, 8);
      expect(page.top[0].metric, LeaderboardMetric.survivalRuns);
    });
  });
}
