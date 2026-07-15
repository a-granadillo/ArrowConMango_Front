import 'package:equatable/equatable.dart';

/// Tracks the player's global progress across levels.
///
/// Stores the list of unlocked level IDs and the current session token.
class AppProgress extends Equatable {
  /// Ordered list of level IDs the player has unlocked.
  final List<int> unlockedLevels;

  /// Current authentication/session token.
  final String currentToken;

  const AppProgress({
    this.unlockedLevels = const [],
    this.currentToken = '',
  });

  /// Returns a new [AppProgress] with [levelId] unlocked.
  ///
  /// If [levelId] is already unlocked, returns `this`.
  AppProgress unlockLevel(int levelId) {
    if (unlockedLevels.contains(levelId)) return this;
    return AppProgress(
      unlockedLevels: [...unlockedLevels, levelId]..sort(),
      currentToken: currentToken,
    );
  }

  @override
  List<Object?> get props => [unlockedLevels, currentToken];

  @override
  String toString() =>
      'AppProgress(unlocked: $unlockedLevels, token: $currentToken)';
}
