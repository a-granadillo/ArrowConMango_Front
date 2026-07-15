import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_svgs.dart';
import '../../../../core/widgets/mango_logo.dart';
import '../../../../l10n/app_localizations.dart';
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
                            padding: const EdgeInsets.all(12),
                            child: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: AppColors.textDark,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x526D4C2A),
                                    blurRadius: 28,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
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
                      vertical: 10,
                    ),
                    child: Text(
                      'Arrastra para rotar el cubo. Toca una flecha para '
                      'sacarla si su salida está libre.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        color: AppColors.textMuted,
                      ),
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
        gradient: LinearGradient(
          begin: Alignment(-0.4, -1),
          end: Alignment(0.4, 1),
          colors: [AppColors.successDark, AppColors.success],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _HeaderIconButton(
                svg: AppSvgs.home,
                onTap: () => context.go(AppRoutes.menu),
              ),
              Expanded(
                child: Text(
                  'Cubo 3D',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
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
              Expanded(
                child: _StatChip(
                  svg: AppSvgs.timer,
                  value: '${state.elapsedSeconds}s',
                  label: '',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
      ),
    );
  }
}

/// Outlined "Menú" button, matching the 2D result dialogs' exact styling.
class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => context.go(AppRoutes.menu),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: AppColors.cream2,
        foregroundColor: AppColors.textMuted,
        side: const BorderSide(color: Color(0xFFE8D5C0), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      child: const Text('Menú'),
    );
  }
}

/// Primary gradient action button, matching the 2D result dialogs' "Siguiente
/// nivel"/"Reintentar" styling.
class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, Color(0xFFD85E18)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0xFFA83800), offset: Offset(0, 5)),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.fredoka(
            fontSize: 20,
            letterSpacing: .5,
            color: Colors.white,
          ),
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
    final rating = MangoRating.fromScore(
      points,
      AppLocalizations.of(context)!,
    );

    return ResultSheet(
      confetti: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _PoppingMangoIcon(),
          const SizedBox(height: 10),
          Text(
            '¡CUBO DESPEJADO!',
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(
              fontSize: 36,
              height: 1,
              letterSpacing: 1.5,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            rating.message,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          MangoSlots(filled: rating.stars),
          const SizedBox(height: 8),
          Text(
            '${rating.stars}/3 MANGOS',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: const Color(0xFFC5B8A5),
            ),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: _MenuButton()),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _PrimaryActionButton(
                  label: 'Otro cubo',
                  onTap: onRestart,
                ),
              ),
            ],
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
          const SizedBox(height: 10),
          Text(
            outOfAttempts ? '¡Game Over!' : '¡Oh no!',
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(
              fontSize: 36,
              height: 1,
              letterSpacing: 1.5,
              color: AppColors.danger,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            outOfAttempts
                ? 'Alcanzaste el máximo de ${CubeMangoScoring.maxMistakes} '
                    'errores.'
                : 'Ninguna flecha puede salir ya.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: _MenuButton()),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _PrimaryActionButton(
                  label: 'Reintentar',
                  onTap: onRestart,
                ),
              ),
            ],
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
