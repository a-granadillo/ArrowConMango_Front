import 'package:arrowconmango_front/features/game/application/dtos/level_summary.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_level_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_progress_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';

/// Returns a list of [LevelSummary] entries for every level available.
///
/// Combines the total level count from [ILevelRepository] with the player's
/// progress from [IProgressRepository]. Each entry is marked as unlocked when
/// its [levelId] is present in [AppProgress.unlockedLevels].
///
/// Any repository failure or unhandled exception is surfaced as a
/// [GenericFailure] wrapped in an [Error].
class GetLevelListUseCase {
  final ILevelRepository _levelRepository;
  final IProgressRepository _progressRepository;

  const GetLevelListUseCase(this._levelRepository, this._progressRepository);

  Future<Result<List<LevelSummary>>> call() async {
    try {
      final levelCountResult = await _levelRepository.getLevelCount();
      late final int levelCount;
      switch (levelCountResult) {
        case Success(:final value):
          levelCount = value;
        case Error(:final failure):
          return Error<List<LevelSummary>>(
            GenericFailure('Failed to get level count: ${failure.message}'),
          );
      }

      final progressResult = await _progressRepository.loadProgress();
      late final AppProgress progress;
      switch (progressResult) {
        case Success(:final value):
          progress = value;
        case Error(:final failure):
          return Error<List<LevelSummary>>(
            GenericFailure('Failed to load progress: ${failure.message}'),
          );
      }

      final summaries = List<LevelSummary>.generate(
        levelCount,
        (index) {
          final levelId = index + 1;
          return LevelSummary(
            levelId: levelId,
            isUnlocked: progress.unlockedLevels.contains(levelId),
          );
        },
      );

      return Success<List<LevelSummary>>(summaries);
    } catch (e) {
      return Error<List<LevelSummary>>(
        GenericFailure('Unhandled exception getting level list: $e'),
      );
    }
  }
}
