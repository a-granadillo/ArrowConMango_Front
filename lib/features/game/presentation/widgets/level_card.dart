import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
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
      return BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.mango, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0xFFC87010), offset: Offset(0, 5))],
      );
    }
    if (_locked) {
      return BoxDecoration(
        color: const Color(0xFFEDE0D4),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0xFFC5B8A5), offset: Offset(0, 3))],
      );
    }
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment(-0.6, -1),
        end: Alignment(0.6, 1),
        colors: [Colors.white, Color(0xFFFFF0D4)],
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: Color(0xFFD4C4B0), offset: Offset(0, 4))],
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
          style: GoogleFonts.fredoka(
            fontSize: 30,
            height: 1,
            fontWeight: FontWeight.w600,
            color: numColor,
          ),
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
          Text(
            difficulty,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
      ],
    );
  }

  Widget _lockedContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSvgs.icon(AppSvgs.lock, 18),
        const SizedBox(height: 4),
        Text(
          'Nivel $levelId',
          style: GoogleFonts.nunito(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
