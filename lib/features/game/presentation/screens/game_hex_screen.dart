import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/app_localizations_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_svgs.dart';
import '../../../../core/widgets/mango_logo.dart';
import '../widgets/stat_chip.dart';
import '../../domain/entities/arrow_entity.dart';
import '../../domain/entities/hex_level.dart';
import '../../domain/services/cube_mango_scoring.dart';
import '../bloc/game_state.dart' show DefeatReason;
import '../bloc/hex/hex_game_cubit.dart';
import '../bloc/hex/hex_game_state.dart';
import '../widgets/arrow_color_assigner.dart';
import '../widgets/board_grid_widget.dart' show ExitingArrowData, ImpactingArrowData;
import '../widgets/hex/hex_board_widget.dart';
import '../widgets/mango_rating.dart';
import '../widgets/mango_slots.dart';
import '../widgets/result_sheet.dart';
import '../widgets/result_stat.dart';

/// The hexagonal-board game screen: a sequence of levels of progressively
/// increasing difficulty (like Campaign), played on a hex-shaped board with
/// 6-directional movement instead of a rectangular grid.
///
/// Reuses the same domain play mechanics as the 2D [GameScreen] and
/// [Game3DScreen] (via [HexGameCubit]) — and the same result-dialog chrome
/// ([ResultSheet], [MangoRating]/[MangoSlots], [ResultStatsRow]) and
/// remaining-attempts hearts as the other modes, so all three feel like one
/// system.
class GameHexScreen extends StatefulWidget {
  const GameHexScreen({
    super.key,
    this.externalLevel,
    this.onEditorTestSolved,
  });

  /// Plays this single level instead of the catalogue's progression — used
  /// for creative-mode test-play (pass [onEditorTestSolved]) and for
  /// playing a single published community hex level (omit it).
  final HexLevel? externalLevel;

  /// Called on victory when [externalLevel] is a creative-mode draft being
  /// test-played, instead of submitting a leaderboard score (mirrors
  /// [GameScreen]'s `onEditorTestSolved`).
  final VoidCallback? onEditorTestSolved;

  bool get isEditorTestPlay => onEditorTestSolved != null;

  @override
  State<GameHexScreen> createState() => _GameHexScreenState();
}

class _GameHexScreenState extends State<GameHexScreen> {
  final ArrowColorAssigner _colors = ArrowColorAssigner();
  Timer? _flashTimer;
  Timer? _clockTimer;

  List<ArrowEntity> _prevArrows = const [];
  final List<ExitingArrowData> _exiting = [];
  final List<ImpactingArrowData> _impacting = [];
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    final externalLevel = widget.externalLevel;
    if (externalLevel != null) {
      context.read<HexGameCubit>().loadExternal(
            externalLevel,
            onSolved: widget.onEditorTestSolved,
          );
    } else {
      context.read<HexGameCubit>().loadLevels();
    }
    // The cubit has no internal clock — pump ticks so elapsed time advances.
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) context.read<HexGameCubit>().tick();
    });
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  void _onState(BuildContext context, HexGameState state) {
    if (state.board != null) _syncExiting(state.board!.arrows);

    if (state.lastBlockedId == null) return;
    _spawnImpacting(state);
    _flashTimer?.cancel();
    _flashTimer = Timer(const Duration(milliseconds: 450), () {
      if (mounted) context.read<HexGameCubit>().clearBlockedFlash();
    });
  }

  /// Spawns impact-flash animations for the two arrows that just collided.
  void _spawnImpacting(HexGameState state) {
    final board = state.board;
    if (board == null) return;
    for (final arrowId in {state.lastBlockedId, state.lastBlockingId}) {
      if (arrowId == null) continue;
      final arrow = board.getArrowById(arrowId);
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

  void _retry(BuildContext context) {
    _colors.reset();
    _prevArrows = const [];
    _exiting.clear();
    _impacting.clear();
    context.read<HexGameCubit>().retryLevel();
  }

  void _next(BuildContext context) {
    _colors.reset();
    _prevArrows = const [];
    _exiting.clear();
    _impacting.clear();
    context.read<HexGameCubit>().nextLevel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: BlocConsumer<HexGameCubit, HexGameState>(
        listener: _onState,
        builder: (context, state) {
          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HexHeader(state: state, onRestart: () => _retry(context)),
                  Expanded(
                    child: state.status == HexStatus.loading || state.board == null
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 340,
                                maxHeight: 340,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                child: HexBoardWidget(
                                  radius: state.radius,
                                  arrows: state.board!.arrows,
                                  colorOf: _colors.colorOf,
                                  exitingArrows: _exiting,
                                  impactingArrows: _impacting,
                                  onArrowTap: (id) =>
                                      context.read<HexGameCubit>().tapArrow(id),
                                ),
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      'Toca una flecha para sacarla si su salida está libre.',
                      textAlign: TextAlign.center,
                      style: AppTypography.label(
                        weight: FontWeight.w700,
                      ).copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
              if (state.status == HexStatus.victory)
                Positioned.fill(
                  child: _HexVictorySheet(
                    state: state,
                    onNext: () => _next(context),
                    onRestart: () => _retry(context),
                  ),
                ),
              if (state.status == HexStatus.defeat)
                Positioned.fill(
                  child: _HexDefeatSheet(
                    state: state,
                    onRestart: () => _retry(context),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HexHeader extends StatelessWidget {
  const _HexHeader({required this.state, required this.onRestart});

  final HexGameState state;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(16, top + 20, 16, 14),
      decoration: const BoxDecoration(
        gradient: AppGradients.green,
        borderRadius: AppRadii.headerBottom,
      ),
      child: Column(
        children: [
          Row(
            children: [
              HeaderIconButton(
                svg: AppSvgs.home,
                onTap: () => context.go(AppRoutes.menu),
              ),
              Expanded(
                child: Text(
                  state.totalLevels > 0
                      ? 'Hexagonal — Nivel ${state.levelIndex + 1}/${state.totalLevels}'
                      : 'Hexagonal',
                  textAlign: TextAlign.center,
                  style: AppTypography.headline(),
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
                  label: 'flechas',
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: StatChip(
                  svg: AppSvgs.taps,
                  value: '${state.moveCount}',
                  label: 'toques',
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: StatChip(
                  svg: AppSvgs.timer,
                  value: '${state.elapsedSeconds}s',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          _AttemptsIndicator(
            remaining: CubeMangoScoring.maxMistakes - state.mistakes,
            total: CubeMangoScoring.maxMistakes,
          ),
        ],
      ),
    );
  }
}

/// Remaining-attempts hearts — the exact same ❤️/🖤 language as the 2D
/// game's lives indicator, so "how many mistakes can I still afford" reads
/// identically across every mode.
class _AttemptsIndicator extends StatelessWidget {
  const _AttemptsIndicator({required this.remaining, required this.total});

  final int remaining;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Intentos restantes: $remaining de $total',
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(total, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                index < remaining ? '❤️' : '🖤',
                style: const TextStyle(fontSize: 18),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Victory dialog — the same [ResultSheet]/[MangoRating]/[MangoSlots]/
/// [ResultStatsRow] chrome as the other modes. Offers "Siguiente nivel" when
/// the catalogue has more levels, or "Jugar de nuevo" once it's exhausted.
class _HexVictorySheet extends StatelessWidget {
  const _HexVictorySheet({
    required this.state,
    required this.onNext,
    required this.onRestart,
  });

  final HexGameState state;
  final VoidCallback onNext;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final points = state.score?.totalPoints ?? 0;
    final rating = MangoRating.fromScore(points, context.l10n);

    return ResultSheet(
      confetti: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _PoppingMangoIcon(),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '¡PANAL DESPEJADO!',
            textAlign: TextAlign.center,
            style: AppTypography.titleLg(),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            rating.message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyText(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          MangoSlots(filled: rating.stars),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${rating.stars}/3 MANGOS',
            style: AppTypography.label(
              color: AppColors.stone,
              weight: FontWeight.w800,
            ).copyWith(letterSpacing: 1),
          ),
          const SizedBox(height: AppSpacing.md),
          ResultStatsRow(
            stats: [
              ResultStat(
                value: '${state.moveCount}',
                label: 'Toques',
                color: AppColors.primary,
              ),
              ResultStat(
                value: formatDuration(state.elapsedSeconds),
                label: 'Tiempo',
                color: AppColors.success,
              ),
              ResultStat(
                value: '$points',
                label: 'Mangos',
                color: AppColors.mango,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ResultActionRow(
            secondaryLabel: 'Menú',
            onSecondary: () => context.go(AppRoutes.menu),
            primaryLabel: state.hasNextLevel ? 'Siguiente nivel' : 'Jugar de nuevo',
            onPrimary: state.hasNextLevel ? onNext : onRestart,
          ),
        ],
      ),
    );
  }
}

/// Defeat dialog — mirrors the other modes' chrome (no confetti, danger-red
/// title, same stats card and button language).
class _HexDefeatSheet extends StatelessWidget {
  const _HexDefeatSheet({required this.state, required this.onRestart});

  final HexGameState state;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final outOfAttempts = state.defeatReason == DefeatReason.outOfLives;

    return ResultSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(outOfAttempts ? '💀' : '😵', style: const TextStyle(fontSize: 56)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            outOfAttempts ? '¡Game Over!' : '¡Oh no!',
            textAlign: TextAlign.center,
            style: AppTypography.titleLg(color: AppColors.danger),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            outOfAttempts
                ? 'Alcanzaste el máximo de ${CubeMangoScoring.maxMistakes} '
                    'errores.'
                : 'Ninguna flecha puede salir ya.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyText(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          ResultStatsRow(
            stats: [
              ResultStat(
                value: '${state.moveCount}',
                label: 'Toques',
                color: AppColors.primary,
              ),
              ResultStat(
                value: formatDuration(state.elapsedSeconds),
                label: 'Tiempo',
                color: AppColors.success,
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ResultActionRow(
            secondaryLabel: 'Menú',
            onSecondary: () => context.go(AppRoutes.menu),
            primaryLabel: 'Reintentar',
            onPrimary: onRestart,
          ),
        ],
      ),
    );
  }
}

class _PoppingMangoIcon extends StatefulWidget {
  const _PoppingMangoIcon();

  @override
  State<_PoppingMangoIcon> createState() => _PoppingMangoIconState();
}

class _PoppingMangoIconState extends State<_PoppingMangoIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) =>
          Transform.scale(scale: anim.value.clamp(0.0, 1.2), child: child),
      child: const MangoLogo(size: 66),
    );
  }
}
