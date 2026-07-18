import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/app_localizations_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/menu_buttons.dart';

/// "Jugar" hub: groups the game modes that used to crowd the main menu
/// (Campaign, Survival, Cubo 3D) behind a single entry point.
class PlayHubScreen extends StatelessWidget {
  const PlayHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          AppScreenHeader(
            title: 'Jugar',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.maxContentWidth,
                ),
                child: ListView(
                  padding: AppSpacing.page,
                  children: [
                    PlayButton(
                      label: context.l10n.menuCampaignMode,
                      onTap: () => context.push(AppRoutes.levels),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PlayButton(
                      label: context.l10n.menuSurvivalMode,
                      bg: AppColors.textDark,
                      fg: AppColors.mango,
                      shadow: AppColors.espresso,
                      onTap: () => context.push(AppRoutes.gameFor(-1)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PlayButton(
                      label: 'CUBO 3D',
                      bg: AppColors.success,
                      fg: Colors.white,
                      shadow: AppColors.successDark,
                      onTap: () => context.push(AppRoutes.game3d),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PlayButton(
                      label: 'HEXAGONAL',
                      bg: AppColors.mango,
                      fg: AppColors.textDark,
                      shadow: AppColors.gold,
                      onTap: () => context.push(AppRoutes.gameHex),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
