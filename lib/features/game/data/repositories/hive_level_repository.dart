import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/level_mapper.dart';
import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_level_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

/// Hive-backed implementation of [ILevelRepository].
///
/// Stores [LevelModel] objects in a [Box] keyed by level ID and maps them
/// to domain [Level] / [GameSession] entities on read.
///
/// Not registered as [ILevelRepository] itself — [SyncedLevelRepository]
/// decorates this with backend sync and is the one that fills that role.
@lazySingleton
class HiveLevelRepository implements ILevelRepository {
  final Box<LevelModel> _levelsBox;
  final LevelMapper _levelMapper;

  HiveLevelRepository(
    this._levelsBox,
    this._levelMapper,
  );

  @override
  Future<Result<GameSession>> loadLevel(int levelId) async {
    try {
      final model = _levelsBox.get(levelId);
      if (model == null) {
        return Error<GameSession>(
          GenericFailure('Level $levelId not found'),
        );
      }

      final level = _levelMapper.toEntity(model);
      return Success<GameSession>(
        level.startSession(
          sessionId: _generateSessionId(),
          startedAtMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      return Error<GameSession>(
        GenericFailure('Failed to load level $levelId: $e'),
      );
    }
  }

  @override
  Future<Result<int>> getLevelCount() async {
    try {
      return Success<int>(_levelsBox.length);
    } catch (e) {
      return Error<int>(
        GenericFailure('Failed to get level count: $e'),
      );
    }
  }

  @override
  Future<Result<Level>> getLevelDefinition(int levelId) async {
    try {
      final model = _levelsBox.get(levelId);
      if (model == null) {
        return Error<Level>(
          GenericFailure('Level $levelId not found'),
        );
      }

      return Success<Level>(_levelMapper.toEntity(model));
    } catch (e) {
      return Error<Level>(
        GenericFailure('Failed to get level definition $levelId: $e'),
      );
    }
  }

  String _generateSessionId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_nextSessionSuffix()}';
  }

  int _sessionSuffix = 0;

  int _nextSessionSuffix() {
    _sessionSuffix += 1;
    return _sessionSuffix;
  }
}
