import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mango_background.dart';
import '../../domain/entities/arrow_entity.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/board_grid_widget.dart';
import '../widgets/game_controls_widget.dart';

/// The main gameplay screen. Loads a level into [GameBloc], drives the timer,
/// renders the board and controls, and navigates to the result screens.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.levelId});

  final int levelId;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Timer? _timer;
  List<ArrowEntity> _prevArrows = const [];
  final List<ExitingArrowData> _exiting = [];
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    context.read<GameBloc>().add(LoadLevel(levelId: widget.levelId));
    // The BLoC has no internal clock — pump ticks so the timer advances.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      context
          .read<GameBloc>()
          .add(Tick(nowMs: DateTime.now().millisecondsSinceEpoch));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onState(BuildContext context, GameState state) {
    switch (state) {
      case GamePlaying():
        _syncExiting(state.boardState.arrows);
      case GameLoading():
      case GameInitial():
        _prevArrows = const [];
      case GameVictory():
        _timer?.cancel();
        context.pushReplacement(AppRoutes.victory, extra: state);
      case GameDefeat():
        _timer?.cancel();
        context.pushReplacement(AppRoutes.defeat, extra: state);
      case GameError():
        break;
    }
  }

  /// Spawns exit animations for arrows present last frame but gone this frame.
  void _syncExiting(List<ArrowEntity> current) {
    final currentIds = current.map((a) => a.id).toSet();
    var changed = false;
    for (var i = 0; i < _prevArrows.length; i++) {
      final arrow = _prevArrows[i];
      if (!currentIds.contains(arrow.id)) {
        final id = 'exit_${_seq++}';
        _exiting.add(
          ExitingArrowData(
            id: id,
            arrow: arrow,
            color: BoardGridWidget.colorForIndex(i),
            onComplete: () => _removeExiting(id),
          ),
        );
        changed = true;
      }
    }
    _prevArrows = current;
    if (changed && mounted) setState(() {});
  }

  void _removeExiting(String id) {
    if (!mounted) return;
    setState(() => _exiting.removeWhere((e) => e.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: _onState,
      builder: (context, state) => switch (state) {
        GamePlaying() => _buildPlaying(context, state),
        GameError(:final message) => _buildError(context, message),
        _ => const MangoBackground(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.textOnPrimary),
            ),
          ),
      },
    );
  }

  Widget _buildPlaying(BuildContext context, GamePlaying state) {
    final bloc = context.read<GameBloc>();
    return MangoBackground(
      child: Column(
        children: [
          _Hud(state: state),
          const SizedBox(height: 12),
          Text(
            'Toca una flecha para sacarla del tablero.',
            textAlign: TextAlign.center,
            style: AppTypography.body(14, color: AppColors.textOnPrimary),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: BoardGridWidget(
                rows: state.rows,
                cols: state.cols,
                arrows: state.boardState.arrows,
                exitingArrows: _exiting,
                onArrowTap: (id) =>
                    bloc.add(TriggerArrowExit(arrowId: id)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GameControlsWidget(
            canUndo: state.canUndo,
            onUndo: () => bloc.add(const UndoMove()),
            onRestart: () => bloc.add(const RetryLevel()),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return MangoBackground(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.textOnPrimary, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body(16, color: AppColors.textOnPrimary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.menu),
              child: const Text('Menú'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({required this.state});

  final GamePlaying state;

  static String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => context.go(AppRoutes.menu),
              icon: const Icon(Icons.close_rounded,
                  color: AppColors.textOnPrimary),
            ),
            Expanded(
              child: Text(
                'Nivel ${state.levelId} · ${state.difficulty}',
                textAlign: TextAlign.center,
                style:
                    AppTypography.display(22, color: AppColors.textOnPrimary),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatChip(
              icon: Icons.my_location_rounded,
              label: '${state.arrowsRemaining} flechas',
            ),
            _StatChip(
              icon: Icons.touch_app_rounded,
              label: '${state.moveCount} toques',
            ),
            _StatChip(
              icon: Icons.timer_outlined,
              label: _formatTime(state.elapsedSeconds),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.body(15,
                color: AppColors.textDark, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
