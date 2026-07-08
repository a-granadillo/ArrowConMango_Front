import 'package:arrowconmango_front/features/game/domain/repositories/i_level_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_progress_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';

/// Unlocks the level immediately after [currentLevelId] in the player's
/// local progress.
///
/// If the player has already beaten the last available level, the use case
/// succeeds without mutating progress.
class UnlockNextLevelUseCase {
  final IProgressRepository _progressRepository;
  final ILevelRepository _levelRepository;

  const UnlockNextLevelUseCase({
    required this._progressRepository,
    required this._levelRepository,
  });

  Future<Result<void>> call({required int currentLevelId}) async {
    final countResult = await _levelRepository.getLevelCount();

    switch (countResult) {
      case Success(value: final totalLevels):
        final nextLevelId = currentLevelId + 1;
        if (nextLevelId > totalLevels) {
          return const Success<void>(null);
        }

        final progressResult = await _progressRepository.loadProgress();
        switch (progressResult) {
          case Success(value: final progress):
            final updatedProgress = progress.unlockLevel(nextLevelId);
            return await _progressRepository.saveProgress(updatedProgress);
          case Error(failure: final failure):
            return Error<void>(failure);
        }
      case Error(failure: final failure):
        return Error<void>(failure);
    }
  }
}
