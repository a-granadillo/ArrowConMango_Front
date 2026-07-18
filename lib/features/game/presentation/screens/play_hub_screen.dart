import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/app_localizations_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/menu_buttons.dart';

/// "Jugar" hub: groups the game modes that used to crowd the main menu
/// (Campaign, Survival, Cubo 3D) behind a single entry point.
class PlayHubScreen extends StatelessWidget {
  const PlayHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Jugar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PlayButton(
            label: context.l10n.menuCampaignMode,
            onTap: () => context.push(AppRoutes.levels),
          ),
          const SizedBox(height: 14),
          PlayButton(
            label: context.l10n.menuSurvivalMode,
            bg: AppColors.textDark,
            fg: AppColors.mango,
            shadow: const Color(0xFF3E2723),
            onTap: () => context.push(AppRoutes.gameFor(-1)),
          ),
          const SizedBox(height: 14),
          PlayButton(
            label: 'CUBO 3D',
            bg: AppColors.success,
            fg: Colors.white,
            shadow: AppColors.successDark,
            onTap: () => context.push(AppRoutes.game3d),
          ),
          const SizedBox(height: 14),
          PlayButton(
            label: 'HEXAGONAL',
            bg: AppColors.mango,
            fg: AppColors.textDark,
            shadow: const Color(0xFFB8860B),
            onTap: () => context.push(AppRoutes.gameHex),
          ),
        ],
      ),
    );
  }
}
