import 'package:injectable/injectable.dart';

import '../../domain/entities/board_state.dart';
import '../../domain/entities/hex_level.dart';
import '../../domain/errors/generic_failure.dart';
import '../../domain/repositories/i_hex_level_repository.dart';
import '../../domain/repositories/result.dart';
import '../datasources/remote_hex_level_data_source.dart';
import '../datasources/remote_leaderboard_data_source.dart';
import '../level_definitions/hex_levels.dart';
import '../models/mappers/hex_arrow_mapper.dart';
import '../topologies/hex_topology.dart';

/// [IHexLevelRepository] backed by the backend's hexagonal-mode level
/// catalogue (`GET /levels?shape=hex`), falling back to the local generated
/// catalogue ([HexLevels]) when the backend is unreachable — offline-first,
/// like the campaign catalogue, but held in memory rather than Hive (see the
/// interface doc for why).
///
/// Unlike [SyncedLevelRepository] this doesn't listen for connectivity
/// changes to re-sync in the background: the hexagonal catalogue is small
/// and rarely changes, so a best-effort fetch per [getLevels] call (never
/// blocking, always falling back) is enough.
@LazySingleton(as: IHexLevelRepository)
class HexLevelRepository implements IHexLevelRepository {
  HexLevelRepository(this._levelDataSource, this._leaderboardDataSource);

  final RemoteHexLevelDataSource _levelDataSource;
  final RemoteLeaderboardDataSource _leaderboardDataSource;

  @override
  Future<Result<List<HexLevel>>> getLevels() async {
    try {
      final rows = await _levelDataSource.fetchAll().timeout(
            const Duration(seconds: 5),
          );
      if (rows.isEmpty) {
        return Success<List<HexLevel>>(HexLevels.all);
      }
      return Success<List<HexLevel>>(rows.map(_fromJson).toList());
    } catch (_) {
      // Offline, unreachable, or malformed response — the local generated
      // catalogue is always available and always solvable.
      return Success<List<HexLevel>>(HexLevels.all);
    }
  }

  @override
  Future<Result<void>> submitScore({
    required String levelId,
    required int moves,
    required int elapsedSeconds,
  }) async {
    try {
      await _leaderboardDataSource.submitForLevel(
        levelId: levelId,
        moves: moves,
        elapsedSeconds: elapsedSeconds,
        mode: 'hexagonal',
      );
      return const Success<void>(null);
    } catch (e) {
      return Error<void>(GenericFailure(e.toString()));
    }
  }

  HexLevel _fromJson(Map<String, dynamic> json) {
    final boardSize = json['boardSize'] as Map<String, dynamic>;
    final radius = boardSize['radius'] as int;
    final topology = HexTopology(radius: radius);
    final rules = (json['rules'] as Map<String, dynamic>?) ?? const {};

    final arrows = (json['arrows'] as List<dynamic>)
        .map((a) => HexArrowMapper.fromJson(a as Map<String, dynamic>, topology))
        .toList();

    return HexLevel(
      id: json['id'] as String,
      name: json['name'] as String,
      difficulty: json['difficulty'] as String,
      radius: radius,
      templateBoard: BoardState(arrows: arrows),
      timeLimitSeconds: rules['timeLimitSeconds'] as int?,
    );
  }
}
