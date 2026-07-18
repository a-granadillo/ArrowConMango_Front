import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../game/domain/entities/hex_level.dart';
import '../bloc/hex_creative_list_state.dart';
import '../bloc/hex_my_levels_cubit.dart';

/// Every hexagonal level (draft or published) the current player has
/// authored — the hex sibling of [MyLevelsScreen].
class HexMyLevelsScreen extends StatelessWidget {
  const HexMyLevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HexMyLevelsCubit>(
      create: (_) => sl<HexMyLevelsCubit>()..load(),
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('Mis niveles hexagonales'),
        ),
        body: BlocBuilder<HexMyLevelsCubit, HexCreativeListState>(
          builder: (context, state) {
            return switch (state) {
              HexCreativeListLoading() =>
                const Center(child: CircularProgressIndicator()),
              HexCreativeListError(:final message) => Center(
                  child: Text('Error: $message'),
                ),
              HexCreativeListLoaded(:final levels) => levels.isEmpty
                  ? const Center(
                      child: Text('Aún no has creado ningún nivel hexagonal.'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: levels.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final level = levels[i];
                        return _HexLevelCard(
                          level: level,
                          onTap: () {
                            if (level.isPublished) {
                              context.push(
                                AppRoutes.creativeRankingHex,
                                extra: level,
                              );
                            } else {
                              context.push(
                                AppRoutes.creativeEditorHex,
                                extra: level,
                              );
                            }
                          },
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

class _HexLevelCard extends StatelessWidget {
  const _HexLevelCard({required this.level, required this.onTap});

  final HexLevel level;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(
          level.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${level.difficulty} · radio ${level.radius} · '
          '${level.arrowCount} flechas',
        ),
        trailing: Chip(
          label: Text(level.isPublished ? 'Publicado' : 'Borrador'),
          backgroundColor: level.isPublished
              ? AppColors.success.withValues(alpha: 0.15)
              : AppColors.textMuted.withValues(alpha: 0.15),
          labelStyle: TextStyle(
            color: level.isPublished ? AppColors.success : AppColors.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
