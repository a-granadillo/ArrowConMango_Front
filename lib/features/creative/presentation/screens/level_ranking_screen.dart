import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../game/domain/entities/creative_level.dart';
import '../bloc/level_ranking_cubit.dart';

/// A single community level's own ranking — `GET /leaderboard/:nivel`.
class LevelRankingScreen extends StatelessWidget {
  const LevelRankingScreen({super.key, required this.level});

  final CreativeLevel level;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LevelRankingCubit>(
      create: (_) => sl<LevelRankingCubit>()..load(level.id),
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: Text('Ranking · ${level.name}'),
        ),
        body: BlocBuilder<LevelRankingCubit, LevelRankingState>(
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
                        return Card(
                          elevation: 0,
                          color: entry.isMe ? AppColors.cream2 : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: entry.isMe
                                ? const BorderSide(
                                    color: AppColors.primary, width: 2)
                                : BorderSide.none,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: entry.rank == 1
                                  ? AppColors.mango
                                  : AppColors.cream2,
                              child: Text('${entry.rank}'),
                            ),
                            title: Text(
                              entry.isMe
                                  ? '${entry.displayName} (Tú)'
                                  : entry.displayName,
                            ),
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
