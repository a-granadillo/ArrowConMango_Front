import 'package:equatable/equatable.dart';

import 'level_best.dart';
import 'scoring_strategy.dart';

/// Tracks the player's global progress across levels.
///
/// Stores the list of unlocked level IDs, the current level, and the best
/// recorded run per level (by level ID).
class AppProgress extends Equatable {
  /// Ordered list of level IDs the player has unlocked.
  final List<int> unlockedLevels;

  /// The level the player is currently on.
  final int currentLevel;

  /// Best recorded run per level, keyed by level ID.
  final Map<int, LevelBest> best;

  const AppProgress({
    this.unlockedLevels = const [],
    this.currentLevel = 0,
    this.best = const {},
  });

  /// Returns a new [AppProgress] with [levelId] unlocked.
  ///
  /// If [levelId] is already unlocked, returns `this`.
  AppProgress unlockLevel(int levelId) {
    if (unlockedLevels.contains(levelId)) return this;
    return AppProgress(
      unlockedLevels: [...unlockedLevels, levelId]..sort(),
      currentLevel: currentLevel,
      best: best,
    );
  }

  /// Returns a new [AppProgress] recording [candidate] as the best run for
  /// [levelId], keeping the existing entry if it already scores higher under
  /// [strategy]. Merge-safe: calling this twice with the same (or a worse)
  /// candidate is a no-op, mirroring the backend's
  /// `PlayerProgress.markCompleted`.
  AppProgress withBest(
    int levelId,
    LevelBest candidate,
    ScoringStrategy strategy,
  ) {
    final existing = best[levelId];
    if (existing != null && !_isBetter(candidate, existing, strategy)) {
      return this;
    }
    return AppProgress(
      unlockedLevels: unlockedLevels,
      currentLevel: currentLevel,
      best: {...best, levelId: candidate},
    );
  }

  bool _isBetter(LevelBest a, LevelBest b, ScoringStrategy strategy) {
    final aPoints =
        strategy.calculateScore(a.moves, a.timeElapsedSeconds).totalPoints;
    final bPoints =
        strategy.calculateScore(b.moves, b.timeElapsedSeconds).totalPoints;
    return aPoints > bPoints;
  }

  @override
  List<Object?> get props => [unlockedLevels, currentLevel, best];

  @override
  String toString() =>
      'AppProgress(unlocked: $unlockedLevels, currentLevel: $currentLevel, best: $best)';
}
