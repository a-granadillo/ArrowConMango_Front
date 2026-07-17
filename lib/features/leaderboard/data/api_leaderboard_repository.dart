import 'package:injectable/injectable.dart';

import '../../game/data/datasources/remote_leaderboard_data_source.dart';
import '../../player/domain/guest_player.dart';
import '../domain/i_leaderboard_repository.dart';
import '../domain/leaderboard_entry.dart';
import 'models/player_standing_dto.dart';

/// Real [ILeaderboardRepository], backed by `GET /leaderboard/global`.
///
/// `colorValue` is UI-only and never sent by the backend: it is derived
/// deterministically from the player's `uuid` (hash → palette index) so the
/// same player always gets the same avatar color across loads.
@LazySingleton(as: ILeaderboardRepository)
class ApiLeaderboardRepository implements ILeaderboardRepository {
  ApiLeaderboardRepository(this._dataSource);

  final RemoteLeaderboardDataSource _dataSource;

  static const List<int> _palette = [
    0xFFF4843D,
    0xFF4CAF50,
    0xFF9B6BC7,
    0xFF57A0C7,
    0xFFE85D5D,
    0xFF8BC34A,
    0xFFF9C74F,
  ];

  @override
  Future<List<LeaderboardEntry>> fetchTopPlayers({
    required GuestPlayer currentPlayer,
    int limit = 20,
  }) async {
    final rows = await _dataSource.fetchGlobal(top: limit);
    return [
      for (final json in rows)
        _toEntry(PlayerStandingDto.fromJson(json)),
    ];
  }

  LeaderboardEntry _toEntry(PlayerStandingDto dto) {
    return LeaderboardEntry(
      rank: dto.rank,
      uuid: dto.userId,
      displayName: dto.displayName,
      mangos: dto.mangos,
      levelsCompleted: dto.levelsCompleted,
      colorValue: _colorFor(dto.userId),
      isCurrentPlayer: dto.isMe,
    );
  }

  int _colorFor(String uuid) =>
      _palette[uuid.hashCode.abs() % _palette.length];
}
