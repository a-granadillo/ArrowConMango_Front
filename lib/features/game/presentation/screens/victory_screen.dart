import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_info.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mango_background.dart';
import '../bloc/game_state.dart';
import '../bloc/progress_bloc.dart';
import '../bloc/progress_event.dart';
import '../widgets/animations/victory_animation.dart';
import '../widgets/result_stat.dart';

/// Victory screen: celebrates the win, shows the score and offers the next
/// level. Persists the unlock through [ProgressBloc] on entry.
class VictoryScreen extends StatefulWidget {
  const VictoryScreen({super.key, required this.result});

  final GameVictory result;

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen> {
  @override
  void initState() {
    super.initState();
    // Persist the unlock once, after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProgressBloc>().add(
            ProgressLevelCompleted(currentLevelId: widget.result.levelId),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final hasNext = result.levelId < AppInfo.totalLevels;

    return VictoryAnimation(
      child: MangoBackground(
        gradient: AppGradients.victory,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: Text('🥭', style: TextStyle(fontSize: 88))),
            const SizedBox(height: 12),
            Text(
              '¡ENHORABUENA!',
              textAlign: TextAlign.center,
              style: AppTypography.display(
                34,
                color: AppColors.textOnPrimary,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ResultStat(
                      icon: Icons.emoji_events_rounded,
                      value: '${result.score.totalPoints}',
                      label: 'Mangos',
                      color: AppColors.mango,
                    ),
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
            if (hasNext)
              ElevatedButton.icon(
                onPressed: () => context.pushReplacement(
                  AppRoutes.gameFor(result.levelId + 1),
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Siguiente nivel'),
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
      ),
    );
  }
}
