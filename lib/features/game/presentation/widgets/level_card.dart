import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_svgs.dart';

/// Visual state of a level tile.
enum LevelTileState { locked, unlocked, completed }

/// A level tile in the selection grid — faithful to the design.
class LevelCard extends StatelessWidget {
  const LevelCard({
    super.key,
    required this.levelId,
    required this.state,
    required this.difficulty,
    this.mangosEarned,
    this.onTap,
  });

  final int levelId;
  final LevelTileState state;

  /// Mangos (1-3) earned on this level's best run. Only meaningful when
  /// [state] is [LevelTileState.completed].
  final int? mangosEarned;

  /// Spanish difficulty label shown as the subtitle (Fácil/Medio/Difícil).
  final String difficulty;
  final VoidCallback? onTap;

  bool get _locked => state == LevelTileState.locked;
  bool get _completed => state == LevelTileState.completed;

  Decoration get _decoration {
    if (_completed) {
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.mango, AppColors.primary],
        ),
        borderRadius: AppRadii.lgAll,
        boxShadow: AppShadows.mango,
      );
    }
    if (_locked) {
      return const BoxDecoration(
        color: AppColors.lockedSurface,
        borderRadius: AppRadii.lgAll,
        boxShadow: AppShadows.locked,
      );
    }
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment(-0.6, -1),
        end: Alignment(0.6, 1),
        colors: [Colors.white, AppColors.cream2],
      ),
      borderRadius: AppRadii.lgAll,
      boxShadow: AppShadows.cardRaised,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _locked ? 0.6 : 1,
      child: GestureDetector(
        onTap: _locked ? null : onTap,
        child: Container(
          height: 102,
          decoration: _decoration,
          child: Center(child: _locked ? _lockedContent() : _unlockedContent()),
        ),
      ),
    );
  }

  Widget _unlockedContent() {
    final numColor = _completed ? Colors.white : AppColors.textDark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$levelId',
          style: AppTypography.display(30, color: numColor).copyWith(height: 1),
        ),
        const SizedBox(height: 4),
        if (_completed)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 3),
                Opacity(
                  opacity: i < (mangosEarned ?? 0) ? 1 : 0.35,
                  child: AppSvgs.icon(AppSvgs.miniMango, 14),
                ),
              ],
            ],
          )
        else
          Text(difficulty, style: AppTypography.caption()),
      ],
    );
  }

  Widget _lockedContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSvgs.icon(AppSvgs.lock, 18),
        const SizedBox(height: 4),
        Text('Nivel $levelId', style: AppTypography.caption()),
      ],
    );
  }
}
