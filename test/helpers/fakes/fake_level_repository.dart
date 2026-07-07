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
    final exception = countExceptionToThrow;
    if (exception != null) {
      throw exception;
    }

    final result = countResult;
    if (result == null) {
      throw StateError('Debes configurar countResult en el Arrange del test');
    }
    return result;
  }

  @override
  Future<Result<GameSession>> loadLevel(int levelId) async {
    throw UnimplementedError('loadLevel() should not be called');
  }

  @override
  Future<Result<Level>> getLevelDefinition(int levelId) async {
    requestedLevelId = levelId;

    final exception = definitionExceptionToThrow;
    if (exception != null) {
      throw exception;
    }

    final result = definitionResult;
    if (result == null) {
      throw StateError(
        'Debes configurar definitionResult en el Arrange del test',
      );
    }
    return result;
  }
}
