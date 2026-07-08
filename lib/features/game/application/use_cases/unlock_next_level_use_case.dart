import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/errors/level_not_found_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_level_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_progress_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';

/// Unlocks the level that follows [currentLevelId] and persists the progress.
///
/// Performs the following steps:
/// 1. Validates that [currentLevelId] is positive.
/// 2. Loads the current [AppProgress].
/// 3. Computes `nextLevelId = currentLevelId + 1`.
/// 4. Reads the total level count and validates that the next level exists.
/// 5. Unlocks the next level and saves the updated progress.
///
/// Any repository failure or unhandled exception is surfaced as a domain
/// [Failure] wrapped in an [Error].
class UnlockNextLevelUseCase {
  final IProgressRepository _progressRepository;
  final ILevelRepository _levelRepository;

  const UnlockNextLevelUseCase(this._progressRepository, this._levelRepository);

  Future<Result<AppProgress>> call({required int currentLevelId}) async {
    try {
      if (currentLevelId <= 0) {
        return Error<AppProgress>(
          GenericFailure('currentLevelId must be greater than 0'),
        );
      }

      final progressResult = await _progressRepository.loadProgress();
      late final AppProgress progress;
      switch (progressResult) {
        case Success(:final value):
          progress = value;
        case Error(:final failure):
          return Error<AppProgress>(failure);
      }

      final nextLevelId = currentLevelId + 1;

      final countResult = await _levelRepository.getLevelCount();
      late final int levelCount;
      switch (countResult) {
        case Success(:final value):
          levelCount = value;
        case Error(:final failure):
          return Error<AppProgress>(failure);
      }

      if (nextLevelId > levelCount) {
        return Error<AppProgress>(
          LevelNotFoundFailure(levelId: nextLevelId),
        );
      }

      final updatedProgress = progress.unlockLevel(nextLevelId);

      final saveResult = await _progressRepository.saveProgress(updatedProgress);
      switch (saveResult) {
        case Success<void>():
          return Success<AppProgress>(updatedProgress);
        case Error(:final failure):
          return Error<AppProgress>(failure);
      }
    } catch (e) {
      return Error<AppProgress>(
        GenericFailure('Unhandled exception unlocking next level: $e'),
      );
    }
  }
}
