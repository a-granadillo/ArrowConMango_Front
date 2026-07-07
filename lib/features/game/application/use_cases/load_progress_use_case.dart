import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_progress_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';

/// Loads the player's persisted progress from a local [IProgressRepository].
///
/// The repository already returns a default [AppProgress] when no data has
/// been saved yet. This use case only adds a safety net for unhandled
/// exceptions, translating them into a [GenericFailure] wrapped in an
/// [Error] result.
class LoadProgressUseCase {
  final IProgressRepository _progressRepository;

  const LoadProgressUseCase(this._progressRepository);

  Future<Result<AppProgress>> call() async {
    try {
      return await _progressRepository.loadProgress();
    } catch (e) {
      return Error<AppProgress>(
        GenericFailure('Unhandled exception loading progress: $e'),
      );
    }
  }
}
