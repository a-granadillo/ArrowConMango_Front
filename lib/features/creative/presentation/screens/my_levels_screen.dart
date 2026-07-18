import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../game/domain/entities/creative_level.dart';
import '../bloc/creative_list_state.dart';
import '../bloc/my_levels_cubit.dart';

/// Every level (draft or published) the current player has authored.
class MyLevelsScreen extends StatelessWidget {
  const MyLevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyLevelsCubit>(
      create: (_) => sl<MyLevelsCubit>()..load(),
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: Column(
          children: [
            AppScreenHeader(
              title: 'Mis niveles',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpacing.maxContentWidth,
                  ),
                  child: BlocBuilder<MyLevelsCubit, CreativeListState>(
                    builder: (context, state) {
                      return switch (state) {
                        CreativeListLoading() =>
                          const Center(child: CircularProgressIndicator()),
                        CreativeListError(:final message) => Center(
                            child: Text('Error: $message'),
                          ),
                        CreativeListLoaded(:final levels) => levels.isEmpty
                            ? const Center(
                                child: Text('Aún no has creado ningún nivel.'),
                              )
                            : ListView.separated(
                                padding: AppSpacing.page,
                                itemCount: levels.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, i) {
                                  final level = levels[i];
                                  return _MyLevelCard(
                                    level: level,
                                    onTap: () {
                                      if (level.isPublished) {
                                        context.push(
                                          AppRoutes.creativeRanking,
                                          extra: level,
                                        );
                                      } else {
                                        context.push(
                                          AppRoutes.creativeEditor,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyLevelCard extends StatelessWidget {
  const _MyLevelCard({required this.level, required this.onTap});

  final CreativeLevel level;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(level.name, style: AppTypography.bodyText()),
        subtitle: Text(
          '${level.difficulty} · ${level.rows}×${level.cols} · '
          '${level.arrowCount} flechas',
          style: AppTypography.label(),
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
