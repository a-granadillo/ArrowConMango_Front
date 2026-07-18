import 'package:injectable/injectable.dart';

import '../../domain/entities/board_state.dart';
import '../../domain/entities/hex_level.dart';
import '../../domain/entities/level_rank_entry.dart';
import '../../domain/errors/generic_failure.dart';
import '../../domain/repositories/i_hex_creative_level_repository.dart';
import '../../domain/repositories/result.dart';
import '../datasources/remote_creative_level_data_source.dart';
import '../datasources/remote_leaderboard_data_source.dart';
import '../models/mappers/hex_arrow_mapper.dart';
import '../topologies/hex_topology.dart';

/// [IHexCreativeLevelRepository] backed by the same community-levels
/// endpoints as [ApiCreativeLevelRepository] (`POST/GET/PUT /levels`,
/// `POST /levels/:id/publish`, `GET /levels/community`, `GET /levels/mine`)
/// — those routes serve every board shape, discriminated by the `shape`
/// field in each level's JSON, so this reuses [RemoteCreativeLevelDataSource]
/// unchanged and filters the results to `shape == 'hex'` client-side. No
/// local cache: community levels are remote-only for the lifetime of the
/// current screen/session (same posture as the grid creative repository).
@LazySingleton(as: IHexCreativeLevelRepository)
class ApiHexCreativeLevelRepository implements IHexCreativeLevelRepository {
  ApiHexCreativeLevelRepository(
    this._levelDataSource,
    this._leaderboardDataSource,
  );

  final RemoteCreativeLevelDataSource _levelDataSource;
  final RemoteLeaderboardDataSource _leaderboardDataSource;

  Map<String, dynamic> _toBody(HexLevel level) {
    return {
      'name': level.name,
      'difficulty': level.difficulty,
      'shape': 'hex',
      'boardSize': {'radius': level.radius},
      'arrows': level.templateBoard.arrows.map(HexArrowMapper.toJson).toList(),
      'rules': {
        if (level.timeLimitSeconds != null)
          'timeLimitSeconds': level.timeLimitSeconds,
        if (level.maxMistakes != null) 'maxMistakes': level.maxMistakes,
      },
    };
  }

  HexLevel _fromJson(Map<String, dynamic> json) {
    final boardSize = json['boardSize'] as Map<String, dynamic>;
    final radius = boardSize['radius'] as int;
    final topology = HexTopology(radius: radius);
    final arrows = (json['arrows'] as List<dynamic>)
        .map((a) => HexArrowMapper.fromJson(a as Map<String, dynamic>, topology))
        .toList();
    final rules = (json['rules'] as Map<String, dynamic>?) ?? const {};

    return HexLevel(
      id: json['id'] as String,
      name: json['name'] as String,
      difficulty: json['difficulty'] as String,
      radius: radius,
      templateBoard: BoardState(arrows: arrows),
      authorId: json['authorId'] as String?,
      isPublished: json['isPublished'] as bool? ?? false,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
      timeLimitSeconds: rules['timeLimitSeconds'] as int?,
      maxMistakes: rules['maxMistakes'] as int?,
    );
  }

  Future<Result<HexLevel>> _guarded(
    Future<HexLevel> Function() action,
  ) async {
    try {
      return Success<HexLevel>(await action());
    } catch (e) {
      return Error<HexLevel>(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Result<HexLevel>> createLevel(HexLevel draft) => _guarded(
        () async => _fromJson(await _levelDataSource.create(_toBody(draft))),
      );

  @override
  Future<Result<HexLevel>> updateLevel(HexLevel draft) => _guarded(
        () async => _fromJson(
          await _levelDataSource.update(draft.id, _toBody(draft)),
        ),
      );

  @override
  Future<Result<HexLevel>> publishLevel(String levelId) => _guarded(
        () async => _fromJson(await _levelDataSource.publish(levelId)),
      );

  @override
  Future<Result<List<HexLevel>>> getCommunityLevels({int? top}) async {
    try {
      // Fetched unfiltered (no `top`) since the endpoint's top-N is over
      // every shape — filtering to hex first, then capping locally, avoids
      // under-returning hex levels that were beyond the mixed-shape window.
      final rows = await _levelDataSource.getCommunity();
      final levels =
          rows.where((r) => r['shape'] == 'hex').map(_fromJson).toList();
      return Success<List<HexLevel>>(
        top != null && levels.length > top ? levels.take(top).toList() : levels,
      );
    } catch (e) {
      return Error<List<HexLevel>>(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<HexLevel>>> getMyLevels() async {
    try {
      final rows = await _levelDataSource.getMine();
      final levels =
          rows.where((r) => r['shape'] == 'hex').map(_fromJson).toList();
      return Success<List<HexLevel>>(levels);
    } catch (e) {
      return Error<List<HexLevel>>(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<LevelRankEntry>>> getLevelRanking(
    String levelId, {
    int? top,
  }) async {
    try {
      final rows = await _leaderboardDataSource.fetchByLevel(levelId, top: top);
      final entries = [
        for (var i = 0; i < rows.length; i++)
          LevelRankEntry(
            rank: i + 1,
            userId: rows[i]['userId'] as String,
            moves: rows[i]['moves'] as int,
            timeMs: rows[i]['timeMs'] as int,
            value: rows[i]['value'] as int,
          ),
      ];
      return Success<List<LevelRankEntry>>(entries);
    } catch (e) {
      return Error<List<LevelRankEntry>>(GenericFailure(e.toString()));
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
}
