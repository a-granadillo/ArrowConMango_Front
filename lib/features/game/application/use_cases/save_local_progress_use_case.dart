import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_progress_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';

/// Persists the player's progress using a local [IProgressRepository].
///
/// The use case forwards the [AppProgress] entity to the repository and
/// translates any unhandled exception into a [GenericFailure] wrapped in
/// an [Error] result, keeping the domain contract explicit.
class SaveLocalProgressUseCase {
  final IProgressRepository _progressRepository;

  const SaveLocalProgressUseCase(this._progressRepository);

  Future<Result<void>> call({required AppProgress progress}) async {
    try {
      return await _progressRepository.saveProgress(progress);
    } catch (e) {
      return Error<void>(GenericFailure('Unhandled exception saving progress: $e'));
    }
  }
}
