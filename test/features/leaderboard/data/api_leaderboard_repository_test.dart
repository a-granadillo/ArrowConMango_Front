import 'package:arrowconmango_front/features/game/data/datasources/remote_leaderboard_data_source.dart';
import 'package:arrowconmango_front/features/leaderboard/data/api_leaderboard_repository.dart';
import 'package:arrowconmango_front/features/player/domain/guest_player.dart';
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

  const currentPlayer = GuestPlayer(uuid: 'me', displayName: 'MangoLoco_10');

  test('should_map_backend_rows_into_leaderboard_entries', () async {
    // Arrange
    when(() => dataSource.fetchGlobal(top: any(named: 'top'))).thenAnswer(
      (_) async => [
        {
          'rank': 1,
          'userId': 'u1',
          'displayName': 'MangoReina_88',
          'mangos': 45,
          'levelsCompleted': 15,
          'isMe': false,
        },
        {
          'rank': 2,
          'userId': 'me',
          'displayName': 'MangoLoco_10',
          'mangos': 3,
          'levelsCompleted': 1,
          'isMe': true,
        },
      ],
    );

    // Act
    final entries =
        await repository.fetchTopPlayers(currentPlayer: currentPlayer);

    // Assert
    expect(entries, hasLength(2));
    expect(entries[0].rank, 1);
    expect(entries[0].uuid, 'u1');
    expect(entries[0].displayName, 'MangoReina_88');
    expect(entries[0].mangos, 45);
    expect(entries[0].levelsCompleted, 15);
    expect(entries[0].isCurrentPlayer, isFalse);
    expect(entries[1].isCurrentPlayer, isTrue);
  });

  test('should_derive_a_stable_colorValue_from_the_uuid', () async {
    // Arrange
    when(() => dataSource.fetchGlobal(top: any(named: 'top'))).thenAnswer(
      (_) async => [
        {
          'rank': 1,
          'userId': 'stable-uuid',
          'displayName': 'Someone',
          'mangos': 10,
          'levelsCompleted': 2,
          'isMe': false,
        },
      ],
    );

    // Act
    final first =
        await repository.fetchTopPlayers(currentPlayer: currentPlayer);
    final second =
        await repository.fetchTopPlayers(currentPlayer: currentPlayer);

    // Assert: same uuid always resolves to the same avatar color.
    expect(first.single.colorValue, second.single.colorValue);
  });

  test('should_pass_the_requested_limit_through_to_the_datasource', () async {
    // Arrange
    when(() => dataSource.fetchGlobal(top: any(named: 'top')))
        .thenAnswer((_) async => []);

    // Act
    await repository.fetchTopPlayers(currentPlayer: currentPlayer, limit: 5);

    // Assert
    verify(() => dataSource.fetchGlobal(top: 5)).called(1);
  });
}
