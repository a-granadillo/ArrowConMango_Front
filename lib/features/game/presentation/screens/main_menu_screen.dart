import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mango_background.dart';
import '../../../player/domain/guest_player.dart';
import '../../../player/presentation/player_cubit.dart';

/// Main menu: title, guest greeting and the primary navigation actions.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MangoBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Center(child: Text('🥭', style: TextStyle(fontSize: 80))),
          const SizedBox(height: 8),
          Text(
            'ARROW CON MANGO',
            textAlign: TextAlign.center,
            style: AppTypography.display(
              34,
              color: AppColors.textOnPrimary,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          BlocBuilder<PlayerCubit, GuestPlayer>(
            builder: (context, player) => Text(
              '¡Hola, ${player.displayName}!',
              textAlign: TextAlign.center,
              style: AppTypography.body(16, color: AppColors.textOnPrimary),
            ),
          ),
          const Spacer(),
          _MenuButton(
            label: 'JUGAR',
            icon: Icons.play_arrow_rounded,
            onPressed: () => context.push(AppRoutes.levels),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            label: 'Ranking',
            icon: Icons.leaderboard_rounded,
            onPressed: () => context.push(AppRoutes.ranking),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            label: 'Ajustes',
            icon: Icons.settings_rounded,
            onPressed: () => context.push(AppRoutes.settings),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(60),
      ),
    );
  }
}
