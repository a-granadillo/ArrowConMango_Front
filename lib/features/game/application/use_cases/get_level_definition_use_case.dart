import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_level_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';

/// Retrieves the [Level] definition for a given [levelId].
///
/// Validates that the identifier is positive before delegating to the
/// repository. Any unhandled exception thrown by the repository is captured
/// and returned as a [GenericFailure] wrapped in an [Error].
class GetLevelDefinitionUseCase {
  final ILevelRepository _levelRepository;

  const GetLevelDefinitionUseCase(this._levelRepository);

  Future<Result<Level>> call({required int levelId}) async {
    if (levelId <= 0) {
      return Error<Level>(
        GenericFailure('levelId must be greater than 0'),
      );
    }

    try {
      return await _levelRepository.getLevelDefinition(levelId);
    } catch (e) {
      return Error<Level>(
        GenericFailure('Unhandled exception getting level definition: $e'),
      );
    }
  }
}
