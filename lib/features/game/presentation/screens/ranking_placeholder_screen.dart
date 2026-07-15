import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/app_localizations_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mango_background.dart';
import '../../../player/domain/guest_player.dart';
import '../../../player/presentation/player_cubit.dart';

/// Placeholder for the future Global Leaderboard (Guest-First).
///
/// The full ranking screen + optional social sign-in is deferred to its own
/// issue. For now it shows the current guest identity so the entry point is
/// meaningful.
class RankingPlaceholderScreen extends StatelessWidget {
  const RankingPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MangoBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textOnPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.rankingTitle,
                style:
                    AppTypography.display(26, color: AppColors.textOnPrimary),
              ),
            ],
          ),
          const Spacer(),
          const Center(
            child: Icon(Icons.leaderboard_rounded,
                color: AppColors.textOnPrimary, size: 64),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.rankingComingSoon,
            textAlign: TextAlign.center,
            style: AppTypography.body(16, color: AppColors.textOnPrimary),
          ),
          const SizedBox(height: 8),
          BlocBuilder<PlayerCubit, GuestPlayer>(
            builder: (context, player) => Text(
              l10n.rankingPlayAs(player.displayName),
              textAlign: TextAlign.center,
              style: AppTypography.body(
                14,
                color: AppColors.textOnPrimary,
                weight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
