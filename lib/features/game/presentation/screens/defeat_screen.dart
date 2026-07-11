import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mango_background.dart';
import '../bloc/game_state.dart';
import '../widgets/result_stat.dart';

/// Defeat screen: explains why the level was lost and offers a retry.
class DefeatScreen extends StatelessWidget {
  const DefeatScreen({super.key, required this.result});

  final GameDefeat result;

  String get _reasonText => switch (result.reason) {
        DefeatReason.timeExpired => '¡Se acabó el tiempo!',
        DefeatReason.noMovesAvailable => 'No quedan movimientos posibles.',
      };

  @override
  Widget build(BuildContext context) {
    return MangoBackground(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: Text('😵', style: TextStyle(fontSize: 88))),
          const SizedBox(height: 12),
          Text(
            '¡Oh no!',
            textAlign: TextAlign.center,
            style: AppTypography.display(
              34,
              color: AppColors.textOnPrimary,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _reasonText,
            textAlign: TextAlign.center,
            style: AppTypography.body(16, color: AppColors.textOnPrimary),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ResultStat(
                    icon: Icons.touch_app_rounded,
                    value: '${result.moveCount}',
                    label: 'Toques',
                  ),
                  ResultStat(
                    icon: Icons.timer_outlined,
                    value: formatDuration(result.elapsedSeconds),
                    label: 'Tiempo',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () =>
                context.pushReplacement(AppRoutes.gameFor(result.levelId)),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.menu),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: AppColors.textOnPrimary,
              side: const BorderSide(color: AppColors.textOnPrimary, width: 2),
            ),
            child: const Text('Menú'),
          ),
        ],
      ),
    );
  }
}
