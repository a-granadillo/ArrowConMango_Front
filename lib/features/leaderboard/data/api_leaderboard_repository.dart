import 'package:injectable/injectable.dart';

import '../../game/data/datasources/remote_leaderboard_data_source.dart';
import '../domain/i_leaderboard_repository.dart';
import '../domain/leaderboard_entry.dart';

/// Real [ILeaderboardRepository], backed by `GET /leaderboard/:nivel` and
/// `GET /leaderboard/supervivencia`.
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
  Future<LeaderboardPage> fetchByLevel({
    required String levelId,
    int top = 10,
  }) async {
    final json = await _dataSource.fetchByLevel(levelId, top: top);
    return _pageFrom(json, _levelEntryFrom);
  }

  @override
  Future<LeaderboardPage> fetchSurvival({int top = 10}) async {
    final json = await _dataSource.fetchSurvival(top: top);
    return _pageFrom(json, _survivalEntryFrom);
  }

  LeaderboardPage _pageFrom(
    Map<String, dynamic> json,
    LeaderboardEntry Function(Map<String, dynamic>) toEntry,
  ) {
    final top = (json['top'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(toEntry)
        .toList();
    final meJson = json['me'] as Map<String, dynamic>?;
    return LeaderboardPage(
      top: top,
      me: meJson == null ? null : toEntry(meJson),
    );
  }

  LeaderboardEntry _levelEntryFrom(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      uuid: json['userId'] as String,
      displayName: json['displayName'] as String,
      mangos: json['value'] as int,
      colorValue: _colorFor(json['userId'] as String),
      secondaryValue: json['moves'] as int,
      metric: LeaderboardMetric.moves,
      isCurrentPlayer: json['isMe'] as bool,
    );
  }

  LeaderboardEntry _survivalEntryFrom(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      uuid: json['userId'] as String,
      displayName: json['displayName'] as String,
      mangos: json['mangos'] as int,
      colorValue: _colorFor(json['userId'] as String),
      secondaryValue: json['runs'] as int,
      metric: LeaderboardMetric.survivalRuns,
      isCurrentPlayer: json['isMe'] as bool,
    );
  }

  int _colorFor(String uuid) =>
      _palette[uuid.hashCode.abs() % _palette.length];
}
