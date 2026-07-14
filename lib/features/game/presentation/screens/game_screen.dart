import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/audio_track.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_svgs.dart';
import '../../domain/entities/arrow_entity.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/arrow_color_assigner.dart';
import '../widgets/board_grid_widget.dart';
import '../widgets/game_controls_widget.dart';

/// The main gameplay screen. Loads a level into [GameBloc], drives the timer,
/// renders the board and controls, and navigates to the result screens.
///
/// Faithful reproduction of the design's "Juego" screen: orange gradient
/// header with home/restart icons and 3 translucent stat chips, dark-wood
/// framed board, and the exact instruction copy below it.
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
  final ArrowColorAssigner _colors = ArrowColorAssigner();
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
        _colors.reset();
      case GameVictory():
        _timer?.cancel();
        if (state.isEndlessMode) {
          // En modo supervivencia, hacemos push en vez de pushReplacement
          // y pasamos el bloc para preservar el estado
          context.push(AppRoutes.victory, extra: {
            'result': state,
            'bloc': context.read<GameBloc>(),
          });
        } else {
          context.pushReplacement(AppRoutes.victory, extra: state);
        }
      case GameDefeat():
        _timer?.cancel();
        if (state.isEndlessMode) {
          // En modo supervivencia, hacemos push en vez de pushReplacement
          // y pasamos el bloc para preservar el estado
          context.push(AppRoutes.defeat, extra: {
            'result': state,
            'bloc': context.read<GameBloc>(),
          });
        } else {
          context.pushReplacement(AppRoutes.defeat, extra: state);
        }
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
            color: _colors.colorOf(arrow.id),
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
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: BlocConsumer<GameBloc, GameState>(
        listener: _onState,
        builder: (context, state) => switch (state) {
          GamePlaying() => _buildPlaying(context, state),
          GameError(:final message) => _buildError(context, message),
          _ => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        },
      ),
    );
  }

  Widget _buildPlaying(BuildContext context, GamePlaying state) {
    final bloc = context.read<GameBloc>();
    return Column(
      children: [
        _Header(
          state: state,
          onHome: () {
            context.read<AudioService>().playBgm(AudioTrack.menuTheme);
            context.go(AppRoutes.menu);
          },
          onRestart: () => bloc.add(const RetryLevel()),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: BoardGridWidget(
                        rows: state.rows,
                        cols: state.cols,
                        arrows: state.boardState.arrows,
                        exitingArrows: _exiting,
                        colorOf: _colors.colorOf,
                        onArrowTap: (id) =>
                            bloc.add(TriggerArrowExit(arrowId: id)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 13),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  'Toca una flecha para sacarla del tablero.\n'
                  'Solo queda bloqueada si otra flecha cruza su salida.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GameControlsWidget(
                canUndo: state.canUndo,
                onUndo: () => bloc.add(const UndoMove()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.primary, size: 40),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.menu),
            child: const Text('Menú'),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.state,
    required this.onHome,
    required this.onRestart,
  });

  final GamePlaying state;
  final VoidCallback onHome;
  final VoidCallback onRestart;

  static String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static String _difficultyEs(String difficulty) => switch (difficulty) {
        'Easy' => 'Fácil',
        'Medium' => 'Medio',
        'Hard' => 'Difícil',
        _ => difficulty,
      };

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final title = state.levelName.isNotEmpty
        ? state.levelName
        : 'Nivel ${state.levelId}';
    return Container(
      padding: EdgeInsets.fromLTRB(16, top + 20, 16, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.4, -1),
          end: Alignment(0.4, 1),
          colors: [AppColors.primary, Color(0xFFF9A84D)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _HeaderIconButton(svg: AppSvgs.home, onTap: onHome),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.fredoka(
                        fontSize: 19,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Nivel ${state.levelId} · ${_difficultyEs(state.difficulty)}',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              _HeaderIconButton(svg: AppSvgs.restart, onTap: onRestart),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  svg: AppSvgs.arrowsRemaining,
                  value: '${state.arrowsRemaining}',
                  label: 'flechas',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  svg: AppSvgs.taps,
                  value: '${state.moveCount}',
                  label: 'toques',
                ),
              ),
              const SizedBox(width: 8),
              if (state.isEndlessMode)
                Expanded(
                  child: _StatChip(
                    svg: AppSvgs.timer,
                    value: _formatTime(state.totalTimeRemaining),
                    label: '',
                  ),
                )
              else
                Expanded(
                  child: _StatChip(
                    svg: AppSvgs.timer,
                    value: _formatTime(state.elapsedSeconds),
                    label: '',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _LivesIndicator(lives: state.livesRemaining),
              ),
              if (state.isEndlessMode) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _StatChip(
                    svg: AppSvgs.niveles,
                    value: '${state.levelsCompleted}',
                    label: 'niveles',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.svg, required this.onTap});

  final String svg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(10),
        ),
        child: AppSvgs.icon(svg, 17),
      ),
    );
  }
}

class _LivesIndicator extends StatelessWidget {
  const _LivesIndicator({required this.lives});

  final int lives;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Vidas: $lives de 3',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                index < lives ? '❤️' : '🖤',
                style: const TextStyle(fontSize: 18),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.svg,
    required this.value,
    required this.label,
  });

  final String svg;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgs.icon(svg, 15),
          const SizedBox(width: 6),
          Text(
            value,
            style: GoogleFonts.fredoka(fontSize: 20, color: Colors.white),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
