import 'package:arrowconmango_front/features/game/data/models/app_progress_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_best_model.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level_best.dart';
import 'package:injectable/injectable.dart';

/// Converts [AppProgressModel] to/from [AppProgress].
@lazySingleton
class AppProgressMapper {
  const AppProgressMapper();

  AppProgress toEntity(AppProgressModel model) {
    final best = model.best;
    return AppProgress(
      unlockedLevels: [...model.completedLevels]..sort(),
      currentLevel: model.currentLevel,
      best: best == null
          ? const {}
          : best.map(
              (levelId, levelBestModel) => MapEntry(
                levelId,
                LevelBest(
                  moves: levelBestModel.moves,
                  timeElapsedSeconds: levelBestModel.timeElapsedSeconds,
                ),
              ),
            ),
    );
  }

  AppProgressModel toModel(AppProgress entity) {
    return AppProgressModel(
      currentLevel: entity.currentLevel,
      completedLevels: [...entity.unlockedLevels],
      best: entity.best.isEmpty
          ? null
          : entity.best.map(
              (levelId, best) => MapEntry(
                levelId,
                LevelBestModel(
                  moves: best.moves,
                  timeElapsedSeconds: best.timeElapsedSeconds,
                ),
              ),
            ),
    );
  }
}
