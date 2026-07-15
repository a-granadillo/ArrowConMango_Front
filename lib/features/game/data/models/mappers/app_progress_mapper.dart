import 'package:arrowconmango_front/features/game/data/models/app_progress_model.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:injectable/injectable.dart';

/// Converts [AppProgressModel] to/from [AppProgress].
///
/// The domain [AppProgress] entity stores progress as a sorted list of
/// unlocked levels and an opaque token. The data model adds a dedicated
/// current-level indicator and optional per-level scores, so the conversion
/// is lossy for scores and the token is used to persist the current level.
///
/// **TODO:** Consider adding a `currentLevel` field to [AppProgress] entity
/// instead of repurposing `currentToken`, which is semantically meant for
/// authentication/session state.
@lazySingleton
class AppProgressMapper {
  const AppProgressMapper();

  AppProgress toEntity(AppProgressModel model) {
    return AppProgress(
      unlockedLevels: [...model.completedLevels]..sort(),
      currentToken: model.currentLevel.toString(),
    );
  }

  AppProgressModel toModel(AppProgress entity) {
    final completedLevels = [...entity.unlockedLevels];
    final currentLevel = int.tryParse(entity.currentToken) ??
        (completedLevels.isEmpty ? 0 : completedLevels.last);

    return AppProgressModel(
      currentLevel: currentLevel,
      completedLevels: completedLevels,
      scores: null,
    );
  }
}
