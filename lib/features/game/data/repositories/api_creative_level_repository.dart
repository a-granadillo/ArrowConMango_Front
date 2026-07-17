import 'package:injectable/injectable.dart';

import '../../domain/entities/creative_level.dart';
import '../../domain/entities/level_rank_entry.dart';
import '../../domain/errors/generic_failure.dart';
import '../../domain/repositories/i_creative_level_repository.dart';
import '../../domain/repositories/result.dart';
import '../datasources/remote_creative_level_data_source.dart';
import '../datasources/remote_leaderboard_data_source.dart';
import '../models/arrow_model.dart';
import '../models/board_state_model.dart';
import '../models/mappers/board_state_mapper.dart';

/// [ICreativeLevelRepository] backed by the backend's community-levels and
/// per-level-leaderboard endpoints. No local cache: community levels are
/// remote-only for the lifetime of the current screen/session.
@LazySingleton(as: ICreativeLevelRepository)
class ApiCreativeLevelRepository implements ICreativeLevelRepository {
  ApiCreativeLevelRepository(
    this._levelDataSource,
    this._leaderboardDataSource,
    this._boardStateMapper,
  );

  final RemoteCreativeLevelDataSource _levelDataSource;
  final RemoteLeaderboardDataSource _leaderboardDataSource;
  final BoardStateMapper _boardStateMapper;

  Map<String, dynamic> _toBody(CreativeLevel level) {
    final boardModel = _boardStateMapper.toModel(level.templateBoard);
    return {
      'name': level.name,
      'difficulty': level.difficulty,
      'boardSize': {'rows': level.rows, 'cols': level.cols},
      'arrows': boardModel.arrows.map((a) => a.toJson()).toList(),
      'rules': {
        if (level.timeLimitSeconds != null)
          'timeLimitSeconds': level.timeLimitSeconds,
        if (level.maxMistakes != null) 'maxMistakes': level.maxMistakes,
      },
    };
  }

  CreativeLevel _fromJson(Map<String, dynamic> json) {
    final boardSize = json['boardSize'] as Map<String, dynamic>;
    final boardModel = BoardStateModel(
      arrows: (json['arrows'] as List<dynamic>)
          .map((a) => ArrowModel.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
    final rules = (json['rules'] as Map<String, dynamic>?) ?? const {};
    return CreativeLevel(
      id: json['id'] as String,
      name: json['name'] as String,
      difficulty: json['difficulty'] as String,
      rows: boardSize['rows'] as int,
      cols: boardSize['cols'] as int,
      templateBoard: _boardStateMapper.toEntity(boardModel),
      authorId: json['authorId'] as String?,
      isPublished: json['isPublished'] as bool? ?? false,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
      timeLimitSeconds: rules['timeLimitSeconds'] as int?,
      maxMistakes: rules['maxMistakes'] as int?,
    );
  }

  Future<Result<CreativeLevel>> _guarded(
    Future<CreativeLevel> Function() action,
  ) async {
    try {
      return Success<CreativeLevel>(await action());
    } catch (e) {
      return Error<CreativeLevel>(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Result<CreativeLevel>> createLevel(CreativeLevel draft) => _guarded(
        () async => _fromJson(await _levelDataSource.create(_toBody(draft))),
      );

  @override
  Future<Result<CreativeLevel>> updateLevel(CreativeLevel draft) => _guarded(
        () async => _fromJson(
          await _levelDataSource.update(draft.id, _toBody(draft)),
        ),
      );

  @override
  Future<Result<CreativeLevel>> publishLevel(String levelId) => _guarded(
        () async => _fromJson(await _levelDataSource.publish(levelId)),
      );

  @override
  Future<Result<List<CreativeLevel>>> getCommunityLevels({int? top}) async {
    try {
      final rows = await _levelDataSource.getCommunity(top: top);
      return Success<List<CreativeLevel>>(rows.map(_fromJson).toList());
    } catch (e) {
      return Error<List<CreativeLevel>>(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<CreativeLevel>>> getMyLevels() async {
    try {
      final rows = await _levelDataSource.getMine();
      return Success<List<CreativeLevel>>(rows.map(_fromJson).toList());
    } catch (e) {
      return Error<List<CreativeLevel>>(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<LevelRankEntry>>> getLevelRanking(
    String levelId, {
    int? top,
  }) async {
    try {
      final rows = await _leaderboardDataSource.fetchByLevel(
        levelId,
        top: top,
      );
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
      );
      return const Success<void>(null);
    } catch (e) {
      return Error<void>(GenericFailure(e.toString()));
    }
  }
}
