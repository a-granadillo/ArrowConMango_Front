import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_level_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';

/// Manual fake for [ILevelRepository] shared across level use-case tests.
///
/// Allows tests to configure the results returned by [getLevelCount] and
/// [getLevelDefinition], simulate unhandled exceptions, and inspect the
/// [levelId] passed into [getLevelDefinition].
class FakeLevelRepository implements ILevelRepository {
  Result<int>? countResult;
  Result<Level>? definitionResult;
  Object? countExceptionToThrow;
  Object? definitionExceptionToThrow;
  int? requestedLevelId;

  @override
  Future<Result<int>> getLevelCount() async {
    if (countExceptionToThrow != null) {
      throw countExceptionToThrow!;
    }

    return countResult!;
  }

  @override
  Future<Result<GameSession>> loadLevel(int levelId) async {
    throw UnimplementedError('loadLevel() should not be called');
  }

  @override
  Future<Result<Level>> getLevelDefinition(int levelId) async {
    requestedLevelId = levelId;

    if (definitionExceptionToThrow != null) {
      throw definitionExceptionToThrow!;
    }

    return definitionResult!;
  }
}
