import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/audio_track.dart';
import '../../../../core/i18n/app_localizations_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_svgs.dart';
import '../widgets/stat_chip.dart';
import '../../domain/entities/arrow_entity.dart';
import '../../domain/entities/level.dart';
import '../bloc/arrow_collision_event.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/arrow_color_assigner.dart';
import '../widgets/board_grid_widget.dart';
import '../widgets/game_controls_widget.dart';
import '../../../../l10n/app_localizations.dart';

/// The main gameplay screen. Loads a level into [GameBloc], drives the timer,
/// renders the board and controls, and navigates to the result screens.
///
/// Faithful reproduction of the design's "Juego" screen: orange gradient
/// header with home/restart icons and 3 translucent stat chips, dark-wood
/// framed board, and the exact instruction copy below it.
///
/// Plays either a campaign/endless level (pass [levelId]) or an external
/// one — a community level or an editor draft under test — by passing
/// [externalLevel] instead. Exactly one of the two must be set.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    this.levelId,
    this.externalLevel,
    this.externalTimeLimitSeconds,
    this.communityLevelId,
    this.onEditorTestSolved,
  }) : assert(
          (levelId != null) != (externalLevel != null),
          'Pass exactly one of levelId or externalLevel',
        );

  final int? levelId;
  final Level? externalLevel;
  final int? externalTimeLimitSeconds;

  /// When playing a community level, its real backend id — threaded
  /// through to [VictoryScreen]/[DefeatScreen] so a win submits a score
  /// against the level's own ranking rather than local campaign progress.
  final String? communityLevelId;

  /// Set for the editor's "test my draft" session: called on victory to
  /// mark the draft solved in the [LevelEditorCubit] that launched this
  /// play session, instead of persisting anything. A closure (rather than
  /// a communityLevelId-style value) because it must reach back into that
  /// specific, still-alive cubit instance — see [VictoryScreen].
  final VoidCallback? onEditorTestSolved;

  bool get isEditorTestPlay => onEditorTestSolved != null;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Timer? _timer;
  List<ArrowEntity> _prevArrows = const [];
  final List<ExitingArrowData> _exiting = [];
  final List<ImpactingArrowData> _impacting = [];
  StreamSubscription<ArrowCollisionEvent>? _collisionSub;
  final ArrowColorAssigner _colors = ArrowColorAssigner();
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<GameBloc>();
    final externalLevel = widget.externalLevel;
    if (externalLevel != null) {
      bloc.add(
        LoadExternalLevel(
          level: externalLevel,
          timeLimitSeconds: widget.externalTimeLimitSeconds,
        ),
      );
    } else {
      bloc.add(LoadLevel(levelId: widget.levelId!));
    }
    // The BLoC has no internal clock — pump ticks so the timer advances.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      context
          .read<GameBloc>()
          .add(Tick(nowMs: DateTime.now().millisecondsSinceEpoch));
    });
    _collisionSub = bloc.arrowCollisions.listen(_onArrowCollision);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _collisionSub?.cancel();
    super.dispose();
  }

  /// Spawns impact-flash animations for the two arrows that just collided.
  void _onArrowCollision(ArrowCollisionEvent event) {
    if (!mounted) return;
    final arrows = _prevArrows;
    for (final arrowId in {event.movingArrowId, event.blockingArrowId}) {
      ArrowEntity? arrow;
      for (final candidate in arrows) {
        if (candidate.id == arrowId) {
          arrow = candidate;
          break;
        }
      }
      if (arrow == null) continue;
      final id = 'impact_${_seq++}';
      _impacting.add(
        ImpactingArrowData(
          id: id,
          arrow: arrow,
          onComplete: () => _removeImpacting(id),
        ),
      );
    }
    setState(() {});
  }

  void _removeImpacting(String id) {
    if (!mounted) return;
    setState(() => _impacting.removeWhere((e) => e.id == id));
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
        if (state.isEndlessMode || widget.externalLevel != null) {
          // Push (not pushReplacement) + pass the bloc: endless mode and
          // external levels (community/editor test-play) both need RetryLevel
          // / NextEndlessLevel to keep working from the result screen, which
          // requires the same live bloc instance.
          context.push(AppRoutes.victory, extra: {
            'result': state,
            'bloc': context.read<GameBloc>(),
            'communityLevelId': widget.communityLevelId,
            'onEditorTestSolved': widget.onEditorTestSolved,
          });
        } else {
          context.pushReplacement(AppRoutes.victory, extra: state);
        }
      case GameDefeat():
        _timer?.cancel();
        if (state.isEndlessMode || widget.externalLevel != null) {
          context.push(AppRoutes.defeat, extra: {
            'result': state,
            'bloc': context.read<GameBloc>(),
            'communityLevelId': widget.communityLevelId,
            'isEditorTestPlay': widget.isEditorTestPlay,
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
                        impactingArrows: _impacting,
                        colorOf: _colors.colorOf,
                        onArrowTap: (id) =>
                            bloc.add(TriggerArrowExit(arrowId: id)),
                        onArrowLongPress: (id) =>
                            bloc.add(RotateArrow(arrowId: id)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  context.l10n.gameInstructions,
                  textAlign: TextAlign.center,
                  style: AppTypography.label(
                    weight: FontWeight.w700,
                  ).copyWith(height: 1.5),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
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
            child: Text(context.l10n.gameMenuButton),
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

  static String _difficultyEs(String difficulty, AppLocalizations l10n) =>
      switch (difficulty) {
        'Easy' => l10n.difficultyEasy,
        'Medium' => l10n.difficultyMedium,
        'Hard' => l10n.difficultyHard,
        _ => difficulty,
      };

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final l10n = context.l10n;
    final title = state.levelName.isNotEmpty
        ? state.levelName
        : l10n.gameLevelLabel(state.levelId);
    return Container(
      padding: EdgeInsets.fromLTRB(16, top + 20, 16, 14),
      decoration: const BoxDecoration(
        gradient: AppGradients.gameHeader,
        borderRadius: AppRadii.headerBottom,
      ),
      child: Column(
        children: [
          Row(
            children: [
              HeaderIconButton(svg: AppSvgs.home, onTap: onHome),
              Expanded(
                child: Column(
                  children: [
                    Text(title, style: AppTypography.headline()),
                    Text(
                      l10n.gameLevelSubtitle(
                        state.levelId,
                        _difficultyEs(state.difficulty, l10n),
                      ),
                      style: AppTypography.caption(
                        color: Colors.white.withValues(alpha: 0.75),
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              HeaderIconButton(svg: AppSvgs.restart, onTap: onRestart),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: StatChip(
                  svg: AppSvgs.arrowsRemaining,
                  value: '${state.arrowsRemaining}',
                  label: l10n.gameStatArrows,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: StatChip(
                  svg: AppSvgs.taps,
                  value: '${state.moveCount}',
                  label: l10n.gameStatTaps,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: StatChip(
                  svg: AppSvgs.timer,
                  value: _formatTime(
                    state.isEndlessMode
                        ? state.totalTimeRemaining
                        : state.elapsedSeconds,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _LivesIndicator(lives: state.livesRemaining),
              ),
              if (state.isEndlessMode) ...[
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: StatChip(
                    svg: AppSvgs.niveles,
                    value: '${state.levelsCompleted}',
                    label: l10n.gameStatLevels,
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

class _LivesIndicator extends StatelessWidget {
  const _LivesIndicator({required this.lives});

  final int lives;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.gameLivesLabel(lives),
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
