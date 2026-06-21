import 'package:equatable/equatable.dart';

/// User's local progression state — persisted between sessions.
///
/// Tracks which levels have been unlocked and the current authentication
/// token for backend synchronisation.  All mutating methods return new
/// instances (immutability contract).
class AppProgress extends Equatable {
  /// Ordered list of unlocked level IDs.
  final List<int> unlockedLevels;

  /// JWT or session token for backend communication.
  final String currentToken;

  const AppProgress({
    this.unlockedLevels = const [],
    this.currentToken = '',
  });

  /// Returns a new [AppProgress] that includes [levelId] as unlocked.
  ///
  /// If the level was already unlocked the same list is returned (no
  /// duplicate entries are added).
  AppProgress unlockLevel(int levelId) {
    if (unlockedLevels.contains(levelId)) return this;
    return copyWith(unlockedLevels: [...unlockedLevels, levelId]..sort());
  }

  /// Whether [levelId] has been unlocked.
  bool isUnlocked(int levelId) => unlockedLevels.contains(levelId);

  /// Returns a new [AppProgress] with the given [token].
  AppProgress updateToken(String token) => copyWith(currentToken: token);

  /// Creates an [AppProgress] with the specified fields replaced.
  AppProgress copyWith({
    List<int>? unlockedLevels,
    String? currentToken,
  }) {
    return AppProgress(
      unlockedLevels: unlockedLevels ?? this.unlockedLevels,
      currentToken: currentToken ?? this.currentToken,
    );
  }

  @override
  List<Object?> get props => [unlockedLevels, currentToken];

  @override
  String toString() =>
      'AppProgress(unlocked: ${unlockedLevels.length} levels, hasToken: ${currentToken.isNotEmpty})';
}
