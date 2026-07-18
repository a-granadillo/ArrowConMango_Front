import 'package:equatable/equatable.dart';

/// Lightweight read-model (DTO) used by the presentation layer to list levels.
///
/// It intentionally carries only the metadata needed for a level selector,
/// keeping the domain [Level] entity decoupled from UI concerns.
class LevelSummary extends Equatable {
  /// Unique numeric identifier for the level.
  final int levelId;

  /// Whether the player has unlocked this level.
  final bool isUnlocked;

  /// Mangos (1-3) earned on this level's best recorded run, or `null` if the
  /// player has never completed it. This is the authoritative "completed"
  /// signal — unlike whether the *next* level is unlocked, it stays correct
  /// for the last level, which has no next level to unlock.
  final int? mangosEarned;

  const LevelSummary({
    required this.levelId,
    required this.isUnlocked,
    this.mangosEarned,
  });

  bool get isCompleted => mangosEarned != null;

  @override
  List<Object?> get props => [levelId, isUnlocked, mangosEarned];
}
