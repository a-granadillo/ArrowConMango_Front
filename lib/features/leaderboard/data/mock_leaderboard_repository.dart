import '../../player/domain/guest_player.dart';
import '../domain/i_leaderboard_repository.dart';
import '../domain/leaderboard_entry.dart';

/// In-memory [ILeaderboardRepository] that returns a fixed set of fake
/// "cosechadores" with the current guest merged in and ranked by mangos.
///
/// This lets the Guest-First leaderboard UI ship before the backend
/// (`GET /leaderboard`) exists; swapping in a real implementation is a
/// data-layer change only.
class MockLeaderboardRepository implements ILeaderboardRepository {
  /// Fake global players (name, mangos). Deterministic for stable UI/tests.
  static const List<(String, int)> _seed = [
    ('MangoReina_88', 1580),
    ('ArrowKing_07', 1420),
    ('TropiNinja_21', 1310),
    ('GoldenChamp_50', 1185),
    ('FlechaLoca_12', 980),
    ('SunnyBoss_33', 845),
    ('JuicyStar_64', 720),
    ('PixelHero_09', 610),
    ('TurboFan_45', 505),
    ('NinjaPro_77', 390),
    ('MangoLoco_02', 260),
  ];

  /// Demo score assigned to the local guest so they appear mid-table.
  static const int currentPlayerMangos = 640;

  @override
  Future<List<LeaderboardEntry>> fetchTopPlayers({
    required GuestPlayer currentPlayer,
    int limit = 20,
  }) async {
    final rows = <(String uuid, String name, int mangos, bool isMe)>[
      for (final (name, mangos) in _seed) ('seed-$name', name, mangos, false),
      (currentPlayer.uuid, currentPlayer.displayName, currentPlayerMangos, true),
    ]..sort((a, b) => b.$3.compareTo(a.$3));

    return [
      for (var i = 0; i < rows.length && i < limit; i++)
        LeaderboardEntry(
          rank: i + 1,
          uuid: rows[i].$1,
          displayName: rows[i].$2,
          mangos: rows[i].$3,
          isCurrentPlayer: rows[i].$4,
        ),
    ];
  }
}
