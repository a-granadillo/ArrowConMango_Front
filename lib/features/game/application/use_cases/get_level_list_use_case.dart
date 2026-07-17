import 'package:arrowconmango_front/features/game/application/dtos/level_summary.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/entities/scoring_strategy.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_level_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_progress_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/game/domain/services/mango_stars.dart';
import 'package:injectable/injectable.dart';

/// Returns a list of [LevelSummary] entries for every level available.
///
/// Combines the total level count from [ILevelRepository] with the player's
/// progress from [IProgressRepository]. Each entry is marked as unlocked when
/// its [levelId] is present in [AppProgress.unlockedLevels].
///
/// Repository failures are propagated directly so their concrete type is
/// preserved; unhandled exceptions are surfaced as a [GenericFailure].
@lazySingleton
class GetLevelListUseCase {
  final ILevelRepository _levelRepository;
  final IProgressRepository _progressRepository;
  final ScoringStrategy _scoringStrategy;

  const GetLevelListUseCase(
    this._levelRepository,
    this._progressRepository,
    this._scoringStrategy,
  );

  Future<Result<List<LevelSummary>>> call() async {
    try {
      final levelCountResult = await _levelRepository.getLevelCount();
      late final int levelCount;
      switch (levelCountResult) {
        case Success(:final value):
          levelCount = value;
        case Error(:final failure):
          return Error<List<LevelSummary>>(failure);
      }

      final progressResult = await _progressRepository.loadProgress();
      late final AppProgress progress;
      switch (progressResult) {
        case Success(:final value):
          progress = value;
        case Error(:final failure):
          return Error<List<LevelSummary>>(failure);
      }

      final summaries = List<LevelSummary>.generate(
        levelCount,
        (index) {
          final levelId = index + 1;
          final best = progress.best[levelId];
          final mangosEarned = best == null
              ? null
              : MangoStars.fromPoints(
                  _scoringStrategy
                      .calculateScore(best.moves, best.timeElapsedSeconds)
                      .totalPoints,
                );
          return LevelSummary(
            levelId: levelId,
            isUnlocked: progress.unlockedLevels.contains(levelId),
            mangosEarned: mangosEarned,
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
