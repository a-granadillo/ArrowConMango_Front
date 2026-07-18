import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../game/domain/entities/hex_level.dart';
import '../../../game/presentation/bloc/hex/hex_game_cubit.dart';
import '../../../game/presentation/screens/game_hex_screen.dart';
import '../bloc/hex_creative_list_state.dart';
import '../bloc/hex_community_levels_cubit.dart';

/// Published hexagonal levels other players have made — the hex sibling of
/// [CommunityLevelsScreen]: tap to play, or open the trophy icon to see
/// that level's own ranking.
class HexCommunityLevelsScreen extends StatelessWidget {
  const HexCommunityLevelsScreen({super.key});

  void _play(BuildContext context, HexLevel level) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<HexGameCubit>(
          create: (_) => sl<HexGameCubit>(),
          child: GameHexScreen(externalLevel: level),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HexCommunityLevelsCubit>(
      create: (_) => sl<HexCommunityLevelsCubit>()..load(),
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('Comunidad hexagonal'),
        ),
        body: BlocBuilder<HexCommunityLevelsCubit, HexCreativeListState>(
          builder: (context, state) {
            return switch (state) {
              HexCreativeListLoading() =>
                const Center(child: CircularProgressIndicator()),
              HexCreativeListError(:final message) => Center(
                  child: Text('Error: $message'),
                ),
              HexCreativeListLoaded(:final levels) => levels.isEmpty
                  ? const Center(
                      child: Text('Aún no hay niveles hexagonales publicados.'),
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
                              '${level.difficulty} · radio ${level.radius} · '
                              '${level.arrowCount} flechas',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.emoji_events_outlined),
                              tooltip: 'Ver ranking',
                              onPressed: () => context.push(
                                AppRoutes.creativeRankingHex,
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
