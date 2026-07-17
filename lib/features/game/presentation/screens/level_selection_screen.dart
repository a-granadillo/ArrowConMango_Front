import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/sfx_clip.dart';
import '../../../../core/i18n/app_localizations_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_svgs.dart';
import '../../../../core/widgets/mango_logo.dart';
import '../../application/dtos/level_summary.dart';
import '../bloc/menu_bloc.dart';
import '../bloc/menu_event.dart';
import '../bloc/menu_state.dart';
import '../widgets/level_card.dart';
import '../../../../l10n/app_localizations.dart';

/// Level selection — faithful reproduction of the design.
class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  /// Difficulty label matching the current locale.
  static String difficultyFor(int levelId, AppLocalizations l10n) {
    if (levelId <= 5) return l10n.difficultyEasy;
    if (levelId <= 10) return l10n.difficultyMedium;
    return l10n.difficultyHard;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          const _Header(),
          Expanded(
            child: BlocBuilder<MenuBloc, MenuState>(
              builder: (context, state) => switch (state) {
                MenuLoaded(:final levels) => _LevelGrid(levels: levels),
                MenuError(:final message) => _ErrorView(message: message),
                _ => const Center(
                    child: CircularProgressIndicator(color: AppColors.success),
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 20, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.4, -1),
          end: Alignment(0.4, 1),
          colors: [AppColors.successDark, AppColors.success],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          _HeaderBackButton(onTap: () => context.pop()),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.levelSelectTitle,
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                BlocBuilder<MenuBloc, MenuState>(
                  builder: (context, state) {
                    final unlocked = state is MenuLoaded
                        ? state.levels.where((l) => l.isUnlocked).length
                        : 0;
                    final total = state is MenuLoaded ? state.levels.length : 15;
                    return Text(
                      context.l10n.levelSelectAvailable(unlocked, total),
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const MangoLogo(size: 36, leaf: AppColors.mango),
        ],
      ),
    );
  }
}

class _HeaderBackButton extends StatelessWidget {
  const _HeaderBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AppSvgs.icon(AppSvgs.backChevron, 20),
      ),
    );
  }
}

class _LevelGrid extends StatelessWidget {
  const _LevelGrid({required this.levels});

  final List<LevelSummary> levels;

  LevelTileState _stateFor(int index) {
    final level = levels[index];
    if (!level.isUnlocked) return LevelTileState.locked;
    return level.isCompleted ? LevelTileState.completed : LevelTileState.unlocked;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 102,
      ),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        return LevelCard(
          levelId: level.levelId,
          state: _stateFor(index),
          mangosEarned: level.mangosEarned,
          difficulty: LevelSelectionScreen.difficultyFor(
            level.levelId,
            context.l10n,
          ),
          onTap: () {
            context.read<AudioService>().playSfx(SfxClip.click);
            context.push(AppRoutes.gameFor(level.levelId));
          },
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.primary, size: 40),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<MenuBloc>().add(const MenuLevelsRequested()),
            child: Text(context.l10n.levelSelectRetry),
          ),
        ],
      ),
    );
  }
}
