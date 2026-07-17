import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/app_info.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/audio_track.dart';
import '../../../../core/audio/sfx_clip.dart';
import '../../../../core/i18n/app_localizations_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mango_logo.dart';
import 'package:get_it/get_it.dart';

import '../../domain/repositories/i_creative_level_repository.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../bloc/progress_bloc.dart';
import '../bloc/progress_event.dart';
import '../widgets/mango_rating.dart';
import '../widgets/mango_slots.dart';
import '../widgets/result_sheet.dart';
import '../widgets/result_stat.dart';

/// Victory screen: faithful reproduction of the design's "Dialogo
/// Enhorabuena" — a celebratory bottom sheet with confetti, a 1-3 mango
/// rating, stats and the next-level action. On entry, persists the result
/// according to what kind of level was just played:
///  - campaign level: unlocks the next one via [ProgressBloc] (default);
///  - community level ([communityLevelId] set): submits the score to that
///    level's own ranking — never touches local campaign progress, since
///    [result.levelId] is a synthetic id for community levels, not a real
///    campaign slot;
///  - editor test-play ([onEditorTestSolved] set): calls back into the
///    still-alive [LevelEditorCubit] that launched this test session and
///    persists nothing — it's a private rehearsal, not a real play. A
///    closure rather than a BuildContext lookup because go_router pushes
///    this screen as a sibling route, not a descendant of the editor
///    screen's local BlocProvider.
class VictoryScreen extends StatefulWidget {
  const VictoryScreen({
    super.key,
    required this.result,
    this.bloc,
    this.communityLevelId,
    this.onEditorTestSolved,
  });

  final GameVictory result;
  final GameBloc? bloc;
  final String? communityLevelId;
  final VoidCallback? onEditorTestSolved;

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen> {
  AudioService? _audioService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _audioService ??= context.read<AudioService>()
      ..playBgm(AudioTrack.victoryTheme);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final onEditorTestSolved = widget.onEditorTestSolved;
      if (onEditorTestSolved != null) {
        onEditorTestSolved();
        return;
      }
      final communityLevelId = widget.communityLevelId;
      if (communityLevelId != null) {
        // Fire-and-forget, mirroring SubmitScoreUseCase's posture elsewhere:
        // a failed submission has no meaningful UI recovery here, and the
        // level's own ranking screen is where the player would notice.
        GetIt.instance<ICreativeLevelRepository>().submitScore(
          levelId: communityLevelId,
          moves: widget.result.moveCount,
          elapsedSeconds: widget.result.elapsedSeconds,
        );
        return;
      }
      // Persist the unlock once, after the first frame (only in campaign mode).
      if (!widget.result.isEndlessMode) {
        context.read<ProgressBloc>().add(
              ProgressLevelCompleted(
                currentLevelId: widget.result.levelId,
                moves: widget.result.moveCount,
                elapsedSeconds: widget.result.elapsedSeconds,
              ),
            );
      }
    });
  }

  VoidCallback _withClick(VoidCallback action) => () {
    _audioService?.playSfx(SfxClip.click);
    action();
  };

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final l10n = context.l10n;
    final hasNext = result.levelId < AppInfo.totalLevels;
    final rating = MangoRating.fromScore(result.score.totalPoints, l10n);

    return Scaffold(
      body: ResultSheet(
        confetti: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _PoppingMangoIcon(),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                result.isEndlessMode
                    ? l10n.victoryLevelCompleted
                    : l10n.victoryTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 36,
                  height: 1,
                  letterSpacing: 1.5,
                  color: AppColors.primary,
                ),
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
              l10n.victoryMangosLabel(rating.stars),
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
                  value: '${result.moveCount}',
                  label: l10n.victoryStatTaps,
                  color: AppColors.primary,
                ),
                ResultStat(
                  value: formatDuration(result.elapsedSeconds),
                  label: l10n.victoryStatTime,
                  color: AppColors.success,
                ),
                if (result.isEndlessMode) ...[
                  ResultStat(
                    value: '${result.levelsCompleted}',
                    label: l10n.victoryStatLevels,
                    color: AppColors.mango,
                  ),
                  ResultStat(
                    value: '${result.livesRemaining}',
                    label: l10n.victoryStatLives,
                    color: AppColors.danger,
                  ),
                ] else
                  ResultStat(
                    value: '${result.score.totalPoints}',
                    label: l10n.victoryStatMangos,
                    color: AppColors.mango,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                  Expanded(
                  child: OutlinedButton(
                    onPressed: _withClick(() {
                      _audioService?.playBgm(AudioTrack.menuTheme);
                      if (widget.onEditorTestSolved != null ||
                          widget.communityLevelId != null) {
                        // Return to whichever creative screen launched this
                        // play session (editor or community list), rather
                        // than resetting the whole nav stack to the main
                        // menu — that flow pushed exactly [GameScreen, this
                        // screen] on top of it, so two pops land there.
                        context.pop();
                        context.pop();
                      } else {
                        context.go(AppRoutes.menu);
                      }
                    }),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.cream2,
                      foregroundColor: AppColors.textMuted,
                      side: const BorderSide(
                        color: Color(0xFFE8D5C0),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: Text(l10n.victoryMenu),
                  ),
                ),
                if (result.isEndlessMode) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _withClick(() {
                        // Cargar siguiente nivel en modo supervivencia reusando el bloc existente
                        if (widget.bloc != null) {
                          widget.bloc!.add(const NextEndlessLevel());
                          context.pop();
                        } else {
                          final nextLevelId = -(DateTime.now().millisecondsSinceEpoch % 10000 + 1);
                          context.pushReplacement(AppRoutes.gameFor(nextLevelId));
                        }
                      }),
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
                            BoxShadow(
                              color: Color(0xFFA83800),
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          l10n.victoryNextLevel,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            letterSpacing: .5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else if (hasNext) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _withClick(() => context.pushReplacement(
                        AppRoutes.gameFor(result.levelId + 1),
                      )),
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
                            BoxShadow(
                              color: Color(0xFFA83800),
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          l10n.victoryNextLevel,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            letterSpacing: .5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
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
