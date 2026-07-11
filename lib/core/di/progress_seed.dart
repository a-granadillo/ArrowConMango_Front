import 'package:hive/hive.dart';

import '../../features/game/data/models/app_progress_model.dart';
import '../../features/game/data/repositories/hive_progress_repository.dart';

/// Unlocks level 1 for a brand-new guest so there's always something to
/// play — without this, [AppProgress]'s empty default leaves every level
/// locked and the player can never start.
///
/// No-ops if [box] already has a saved record (returning player).
void seedProgressIfEmpty(Box<AppProgressModel> box) {
  if (box.isNotEmpty) return;
  box.put(
    HiveProgressRepository.progressKey,
    const AppProgressModel(currentLevel: 1, completedLevels: [1]),
  );
}
