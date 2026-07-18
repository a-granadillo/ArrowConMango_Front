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
        body: Column(
          children: [
            AppScreenHeader(
              title: 'Mis niveles hexagonales',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpacing.maxContentWidth,
                  ),
                  child: BlocBuilder<HexMyLevelsCubit, HexCreativeListState>(
                    builder: (context, state) {
                      return switch (state) {
                        HexCreativeListLoading() =>
                          const Center(child: CircularProgressIndicator()),
                        HexCreativeListError(:final message) => Center(
                            child: Text('Error: $message'),
                          ),
                        HexCreativeListLoaded(:final levels) => levels.isEmpty
                            ? const Center(
                                child: Text(
                                  'Aún no has creado ningún nivel hexagonal.',
                                ),
                              )
                            : ListView.separated(
                                padding: AppSpacing.page,
                                itemCount: levels.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: AppSpacing.sm),
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
              ),
            ),
          ],
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
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(level.name, style: AppTypography.bodyText()),
        subtitle: Text(
          '${level.difficulty} · radio ${level.radius} · '
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
