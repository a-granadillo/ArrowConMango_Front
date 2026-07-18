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
import '../../data/level_definitions/cube_levels.dart';
import '../../domain/services/cube_mango_scoring.dart';
import '../bloc/cube3d/cube3d_game_cubit.dart';
import '../bloc/cube3d/cube3d_game_state.dart';
import '../bloc/game_state.dart' show DefeatReason;
import '../widgets/arrow_color_assigner.dart';
import '../widgets/cube3d/cube_board_widget.dart';
import '../widgets/mango_rating.dart';
import '../widgets/mango_slots.dart';
import '../widgets/result_sheet.dart';
import '../widgets/result_stat.dart';

/// The rotatable-cube "Tap Away"-style 3D game screen (issue #44).
///
/// Drag anywhere on the cube to orbit it; tap a cubelet's arrow to try to
/// slide it out. Reuses the same domain play mechanics as the 2D
/// [GameScreen] (via [Cube3DGameCubit]) — and the same result-dialog chrome
/// ([ResultSheet], [MangoRating]/[MangoSlots], [ResultStatsRow]) and
/// remaining-attempts hearts as the 2D game, so both feel like one system.
class Game3DScreen extends StatefulWidget {
  const Game3DScreen({super.key});

  @override
  State<Game3DScreen> createState() => _Game3DScreenState();
}

class _Game3DScreenState extends State<Game3DScreen> {
  final ArrowColorAssigner _colors = ArrowColorAssigner();
  Timer? _flashTimer;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    context.read<Cube3DGameCubit>().load(CubeLevels.medium);
    // The cubit has no internal clock — pump ticks so elapsed time advances.
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) context.read<Cube3DGameCubit>().tick();
    });
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  void _onState(BuildContext context, Cube3DGameState state) {
    if (state.lastBlockedId == null) return;
    _flashTimer?.cancel();
    _flashTimer = Timer(const Duration(milliseconds: 450), () {
      if (mounted) context.read<Cube3DGameCubit>().clearBlockedFlash();
    });
  }

  void _restartFresh(BuildContext context) {
    _colors.reset();
    final seed = DateTime.now().millisecondsSinceEpoch;
    context.read<Cube3DGameCubit>().restart(CubeLevels.generateFresh(seed));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: BlocConsumer<Cube3DGameCubit, Cube3DGameState>(
        listener: _onState,
        builder: (context, state) {
          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(state: state, onRestart: () => _restartFresh(context)),
                  Expanded(
                    child: state.status == Cube3DStatus.loading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: AppColors.textDark,
                                borderRadius: BorderRadius.circular(AppRadii.pill),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x526D4C2A),
                                    blurRadius: 28,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadii.sm),
                                child: CubeBoardWidget(
                                  arrows: state.board!.arrows,
                                  width: state.width,
                                  height: state.height,
                                  depth: state.depth,
                                  colorOf: _colors.colorOf,
                                  blockedId: state.lastBlockedId,
                                  onArrowTap: (id) => context
                                      .read<Cube3DGameCubit>()
                                      .tapArrow(id),
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
                      'Arrastra para rotar el cubo. Toca una flecha para '
                      'sacarla si su salida está libre.',
                      textAlign: TextAlign.center,
                      style: AppTypography.label(
                        weight: FontWeight.w700,
                      ).copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
              if (state.status == Cube3DStatus.victory)
                Positioned.fill(
                  child: _Cube3DVictorySheet(
                    state: state,
                    onRestart: () => _restartFresh(context),
                  ),
                ),
              if (state.status == Cube3DStatus.defeat)
                Positioned.fill(
                  child: _Cube3DDefeatSheet(
                    state: state,
                    onRestart: () => _restartFresh(context),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state, required this.onRestart});

  final Cube3DGameState state;
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
                  'Cubo 3D',
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
/// identically in both modes.
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
/// [ResultStatsRow] chrome as [VictoryScreen], so earning "up to 3 mangos"
/// reads identically in the cube mode.
class _Cube3DVictorySheet extends StatelessWidget {
  const _Cube3DVictorySheet({required this.state, required this.onRestart});

  final Cube3DGameState state;
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
            '¡CUBO DESPEJADO!',
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
            primaryLabel: 'Otro cubo',
            onPrimary: onRestart,
          ),
        ],
      ),
    );
  }
}

/// Defeat dialog — mirrors [DefeatScreen]'s chrome (no confetti, danger-red
/// title, same stats card and button language).
class _Cube3DDefeatSheet extends StatelessWidget {
  const _Cube3DDefeatSheet({required this.state, required this.onRestart});

  final Cube3DGameState state;
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
