import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mango_background.dart';
import '../../application/dtos/level_summary.dart';
import '../bloc/menu_bloc.dart';
import '../bloc/menu_event.dart';
import '../bloc/menu_state.dart';
import '../widgets/level_card.dart';

/// Grid of levels with their unlock state. Bound to [MenuBloc].
class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  /// Difficulty label for a level id, mirroring `Level.difficulty()`.
  static String difficultyFor(int levelId) {
    if (levelId <= 5) return 'Easy';
    if (levelId <= 10) return 'Medium';
    return 'Hard';
  }

  @override
  Widget build(BuildContext context) {
    return MangoBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<MenuBloc, MenuState>(
              builder: (context, state) => switch (state) {
                MenuLoaded(:final levels) => _LevelGrid(levels: levels),
                MenuError(:final message) => _ErrorView(message: message),
                _ => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.textOnPrimary,
                    ),
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
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textOnPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seleccionar Nivel',
                style: AppTypography.display(
                  26,
                  color: AppColors.textOnPrimary,
                ),
              ),
              BlocBuilder<MenuBloc, MenuState>(
                builder: (context, state) {
                  if (state is! MenuLoaded) return const SizedBox.shrink();
                  final unlocked =
                      state.levels.where((l) => l.isUnlocked).length;
                  return Text(
                    '$unlocked de ${state.levels.length} disponibles',
                    style: AppTypography.body(
                      14,
                      color: AppColors.textOnPrimary,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LevelGrid extends StatelessWidget {
  const _LevelGrid({required this.levels});

  final List<LevelSummary> levels;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        return LevelCard(
          levelId: level.levelId,
          isUnlocked: level.isUnlocked,
          difficulty: LevelSelectionScreen.difficultyFor(level.levelId),
          onTap: () => context.push(AppRoutes.gameFor(level.levelId)),
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
          const Icon(Icons.error_outline, color: AppColors.textOnPrimary, size: 40),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.body(16, color: AppColors.textOnPrimary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<MenuBloc>().add(const MenuLevelsRequested()),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
