import 'package:injectable/injectable.dart';

import '../../player/domain/guest_player.dart';
import '../domain/i_leaderboard_repository.dart';
import '../domain/leaderboard_entry.dart';

/// In-memory [ILeaderboardRepository] that returns the design's fixed set of
/// "cosechadores" with the current guest merged in and ranked by mangos.
///
/// This lets the Guest-First leaderboard UI ship before the backend
/// (`GET /leaderboard`) exists; swapping in a real implementation is a
/// data-layer change only.
@LazySingleton(as: ILeaderboardRepository)
class MockLeaderboardRepository implements ILeaderboardRepository {
  /// Fake global players (name, mangos, sub, color) — mirrors the approved
  /// design's `PLAYERS` array exactly. Deterministic for stable UI/tests.
  static const List<(String, int, String, int)> _seed = [
    ('MangoMaster', 42, '15 niveles', 0xFFF4843D),
    ('Luisa_G', 37, '13 niveles', 0xFF4CAF50),
    ('PulpaFan', 33, '12 niveles', 0xFF9B6BC7),
    ('Karo22', 28, '11 niveles', 0xFF57A0C7),
    ('DulceVerde', 19, '8 niveles', 0xFFE85D5D),
    ('ElHuertero', 14, '6 niveles', 0xFF8BC34A),
    ('Flechita', 9, '4 niveles', 0xFFF4843D),
  ];

  /// Demo score/sub assigned to the local guest, matching the design's "Tú"
  /// row (which sums the player's own progress) with a plausible demo value.
  static const int currentPlayerMangos = 21;
  static const String currentPlayerSub = '1 nivel';

  /// The design's gold accent used for the current player's avatar.
  static const int currentPlayerColor = 0xFFF9C74F;

  @override
  Future<List<LeaderboardEntry>> fetchTopPlayers({
    required GuestPlayer currentPlayer,
    int limit = 20,
  }) async {
    final rows =
        <(String uuid, String name, int mangos, String sub, int color, bool isMe)>[
      for (final (name, mangos, sub, color) in _seed)
        ('seed-$name', name, mangos, sub, color, false),
      (
        currentPlayer.uuid,
        currentPlayer.displayName,
        currentPlayerMangos,
        currentPlayerSub,
        currentPlayerColor,
        true,
      ),
    ]..sort((a, b) => b.$3.compareTo(a.$3));

    return [
      for (var i = 0; i < rows.length && i < limit; i++)
        LeaderboardEntry(
          rank: i + 1,
          uuid: rows[i].$1,
          displayName: rows[i].$2,
          mangos: rows[i].$3,
          sub: rows[i].$4,
          colorValue: rows[i].$5,
          isCurrentPlayer: rows[i].$6,
        ),
    ];
  }
}
