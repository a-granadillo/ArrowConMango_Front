import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../game/domain/entities/hex_level.dart';
import '../bloc/hex_level_ranking_cubit.dart';
import '../bloc/level_ranking_cubit.dart' show LevelRankingState, LevelRankingLoading, LevelRankingLoaded, LevelRankingError;

/// A single community hex level's own ranking — the hex sibling of
/// [LevelRankingScreen], reusing the same [LevelRankingState] shape.
class HexLevelRankingScreen extends StatelessWidget {
  const HexLevelRankingScreen({super.key, required this.level});

  final HexLevel level;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HexLevelRankingCubit>(
      create: (_) => sl<HexLevelRankingCubit>()..load(level.id),
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: Column(
          children: [
            AppScreenHeader(
              title: 'Ranking · ${level.name}',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpacing.maxContentWidth,
                  ),
                  child: BlocBuilder<HexLevelRankingCubit, LevelRankingState>(
                    builder: (context, state) {
                      return switch (state) {
                        LevelRankingLoading() =>
                          const Center(child: CircularProgressIndicator()),
                        LevelRankingError(:final message) => Center(
                            child: Text('Error: $message'),
                          ),
                        LevelRankingLoaded(:final entries) => entries.isEmpty
                            ? const Center(
                                child: Text(
                                  'Nadie ha completado este nivel todavía.',
                                ),
                              )
                            : ListView.separated(
                                padding: AppSpacing.page,
                                itemCount: entries.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, i) {
                                  final entry = entries[i];
                                  final shortId = entry.userId.length > 8
                                      ? entry.userId.substring(0, 8)
                                      : entry.userId;
                                  return Card(
                                    elevation: 0,
                                    color: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: AppRadii.mdAll,
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      leading: CircleAvatar(
                                        backgroundColor: entry.rank == 1
                                            ? AppColors.mango
                                            : AppColors.cream2,
                                        child: Text('${entry.rank}'),
                                      ),
                                      title: Text(
                                        'Jugador $shortId',
                                        style: AppTypography.bodyText(),
                                      ),
                                      subtitle: Text(
                                        '${entry.moves} movimientos · '
                                        '${(entry.timeMs / 1000).toStringAsFixed(1)}s',
                                        style: AppTypography.label(),
                                      ),
                                      trailing: Text(
                                        '${entry.value}',
                                        style: AppTypography.body(
                                          14,
                                          weight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      };
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
