import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
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
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: Text('Ranking · ${level.name}'),
        ),
        body: BlocBuilder<HexLevelRankingCubit, LevelRankingState>(
          builder: (context, state) {
            return switch (state) {
              LevelRankingLoading() =>
                const Center(child: CircularProgressIndicator()),
              LevelRankingError(:final message) => Center(
                  child: Text('Error: $message'),
                ),
              LevelRankingLoaded(:final entries) => entries.isEmpty
                  ? const Center(
                      child: Text('Nadie ha completado este nivel todavía.'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: entries.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final entry = entries[i];
                        final shortId = entry.userId.length > 8
                            ? entry.userId.substring(0, 8)
                            : entry.userId;
                        return Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: entry.rank == 1
                                  ? AppColors.mango
                                  : AppColors.cream2,
                              child: Text('${entry.rank}'),
                            ),
                            title: Text('Jugador $shortId'),
                            subtitle: Text(
                              '${entry.moves} movimientos · '
                              '${(entry.timeMs / 1000).toStringAsFixed(1)}s',
                            ),
                            trailing: Text(
                              '${entry.value}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
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
    );
  }
}
