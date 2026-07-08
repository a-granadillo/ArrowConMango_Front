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

  const LevelSummary({
    required this.levelId,
    required this.isUnlocked,
  });

  @override
  List<Object?> get props => [levelId, isUnlocked];
}
