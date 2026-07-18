import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../game/domain/entities/creative_level.dart';
import '../../../game/presentation/bloc/game_bloc.dart';
import '../../../game/presentation/screens/game_screen.dart';
import '../bloc/creative_list_state.dart';
import '../bloc/community_levels_cubit.dart';

/// Published levels other players have made — tap to play, or open the
/// trophy icon to see that level's own ranking.
class CommunityLevelsScreen extends StatelessWidget {
  const CommunityLevelsScreen({super.key});

  void _play(BuildContext context, CreativeLevel level) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<GameBloc>(
          create: (_) => sl<GameBloc>(),
          child: GameScreen(
            externalLevel: level.toPlayableLevel(
              syntheticId: level.syntheticLevelId,
            ),
            externalTimeLimitSeconds: level.timeLimitSeconds,
            communityLevelId: level.id,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CommunityLevelsCubit>(
      create: (_) => sl<CommunityLevelsCubit>()..load(),
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('Comunidad'),
        ),
        body: BlocBuilder<CommunityLevelsCubit, CreativeListState>(
          builder: (context, state) {
            return switch (state) {
              CreativeListLoading() =>
                const Center(child: CircularProgressIndicator()),
              CreativeListError(:final message) => Center(
                  child: Text('Error: $message'),
                ),
              CreativeListLoaded(:final levels) => levels.isEmpty
                  ? const Center(
                      child: Text('Aún no hay niveles publicados.'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: levels.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final level = levels[i];
                        return Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              level.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${level.difficulty} · ${level.rows}×${level.cols} · '
                              '${level.arrowCount} flechas',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.emoji_events_outlined),
                              tooltip: 'Ver ranking',
                              onPressed: () => context.push(
                                AppRoutes.creativeRanking,
                                extra: level,
                              ),
                            ),
                            onTap: () => _play(context, level),
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
