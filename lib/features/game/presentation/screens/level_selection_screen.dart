import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/sfx_clip.dart';
import '../../../../core/i18n/app_localizations_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_header.dart';
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
          AppScreenHeader(
            title: context.l10n.levelSelectTitle,
            onBack: () => context.pop(),
            trailing: const MangoLogo(size: 36, leaf: AppColors.mango),
            subtitle: BlocBuilder<MenuBloc, MenuState>(
              builder: (context, state) {
                final unlocked = state is MenuLoaded
                    ? state.levels.where((l) => l.isUnlocked).length
                    : 0;
                final total = state is MenuLoaded ? state.levels.length : 15;
                return Text(
                  context.l10n.levelSelectAvailable(unlocked, total),
                  style: AppTypography.label(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                );
              },
            ),
          ),
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: GridView.builder(
          padding: AppSpacing.page,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
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
        ),
      ),
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
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: AppSpacing.md),
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
