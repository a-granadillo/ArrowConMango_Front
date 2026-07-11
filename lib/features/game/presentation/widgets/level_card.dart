import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// A single tappable level tile in the level-selection grid.
///
/// Shows the level number, a difficulty accent color, and a lock overlay when
/// the level is not yet unlocked.
class LevelCard extends StatelessWidget {
  const LevelCard({
    super.key,
    required this.levelId,
    required this.isUnlocked,
    required this.difficulty,
    this.onTap,
  });

  final int levelId;
  final bool isUnlocked;

  /// Difficulty label ("Easy"/"Medium"/"Hard") used for the accent color.
  final String difficulty;

  /// Called when an unlocked card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.forDifficulty(difficulty);

    return Semantics(
      button: true,
      enabled: isUnlocked,
      label: isUnlocked ? 'Nivel $levelId' : 'Nivel $levelId bloqueado',
      child: Material(
        color: isUnlocked ? AppColors.cream : AppColors.beige,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: isUnlocked ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isUnlocked ? accent : AppColors.textMuted,
                width: 3,
              ),
            ),
            child: Center(
              child: isUnlocked
                  ? Text(
                      '$levelId',
                      style: AppTypography.display(28, color: accent),
                    )
                  : Icon(Icons.lock_rounded, color: AppColors.textMuted, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}
