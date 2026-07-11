import 'package:arrowconmango_front/features/leaderboard/data/mock_leaderboard_repository.dart';
import 'package:arrowconmango_front/features/player/domain/guest_player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockLeaderboardRepository', () {
    const guest = GuestPlayer(uuid: 'me-uuid', displayName: 'MangoLoco_10');

    test('should_merge_current_player_and_rank_by_mangos_desc', () async {
      // Arrange
      final repo = MockLeaderboardRepository();

      // Act
      final entries = await repo.fetchTopPlayers(currentPlayer: guest);

      // Assert: current player included, list sorted descending, ranks 1..n.
      final me = entries.firstWhere((e) => e.isCurrentPlayer);
      expect(me.displayName, 'MangoLoco_10');
      expect(me.mangos, MockLeaderboardRepository.currentPlayerMangos);

      for (var i = 0; i < entries.length; i++) {
        expect(entries[i].rank, i + 1);
        if (i > 0) {
          expect(entries[i - 1].mangos >= entries[i].mangos, isTrue);
        }
      }
      expect(entries.where((e) => e.isCurrentPlayer).length, 1);
    });

    test('should_respect_the_limit', () async {
      // Arrange
      final repo = MockLeaderboardRepository();

      // Act
      final entries = await repo.fetchTopPlayers(currentPlayer: guest, limit: 3);

      // Assert
      expect(entries.length, 3);
    });
  });
}
