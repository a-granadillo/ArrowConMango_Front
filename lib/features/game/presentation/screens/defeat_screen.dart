import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/audio_track.dart';
import '../../../../core/audio/sfx_clip.dart';
import '../../../../core/i18n/app_localizations_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/result_sheet.dart';
import '../widgets/result_stat.dart';
import '../../../../l10n/app_localizations.dart';

/// Defeat screen: explains why the level was lost and offers a retry.
///
/// The source design has no defeat/lose dialog to reproduce — this reuses
/// the same [ResultSheet] chrome as the victory screen (bottom sheet, drag
/// handle, stats card, button language) so it reads as part of the same
/// system rather than an ad-hoc screen.
class DefeatScreen extends StatelessWidget {
  const DefeatScreen({
    super.key,
    required this.result,
    this.bloc,
    this.communityLevelId,
    this.isEditorTestPlay = false,
  });

  final GameDefeat result;
  final GameBloc? bloc;
  final String? communityLevelId;
  final bool isEditorTestPlay;

  bool get _isExternalLevel => isEditorTestPlay || communityLevelId != null;

  String _reasonText(AppLocalizations l10n) => switch (result.reason) {
        DefeatReason.timeExpired => l10n.defeatTimeExpired,
        DefeatReason.noMovesAvailable => l10n.defeatNoMoves,
        DefeatReason.outOfLives => l10n.defeatOutOfLives,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final audioService = context.read<AudioService>();
    VoidCallback withClick(VoidCallback action) => () {
      audioService.playSfx(SfxClip.click);
      action();
    };

    final hasLivesRemaining = result.livesRemaining > 0;
    final isGameOver = result.isEndlessMode && !hasLivesRemaining;

    return Scaffold(
      body: ResultSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isGameOver ? '💀' : '😵', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isGameOver ? l10n.defeatGameOver : l10n.defeatOhNo,
              textAlign: TextAlign.center,
              style: AppTypography.titleLg(color: AppColors.danger),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isGameOver ? l10n.defeatNoLivesMessage : _reasonText(l10n),
              textAlign: TextAlign.center,
              style: AppTypography.bodyText(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            ResultStatsRow(
              stats: [
                if (result.isEndlessMode) ...[
                  ResultStat(
                    value: '${result.levelsCompleted}',
                    label: l10n.defeatStatLevels,
                    color: AppColors.primary,
                  ),
                  ResultStat(
                    value: '${result.livesRemaining}',
                    label: l10n.defeatStatLives,
                    color: AppColors.danger,
                    showDivider: false,
                  ),
                ] else ...[
                  ResultStat(
                    value: '${result.moveCount}',
                    label: l10n.defeatStatTaps,
                    color: AppColors.primary,
                  ),
                  ResultStat(
                    value: formatDuration(result.elapsedSeconds),
                    label: l10n.defeatStatTime,
                    color: AppColors.success,
                    showDivider: false,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ResultActionRow(
              secondaryLabel: l10n.defeatMenu,
              onSecondary: withClick(() {
                audioService.playBgm(AudioTrack.menuTheme);
                if (_isExternalLevel) {
                  // See VictoryScreen's Menu button: return to the
                  // editor/community screen that launched this play session
                  // instead of resetting the whole nav stack.
                  context.pop();
                  context.pop();
                } else {
                  context.go(AppRoutes.menu);
                }
              }),
              primaryLabel: isGameOver ? l10n.defeatRestart : l10n.defeatRetry,
              onPrimary: withClick(() {
                if ((result.isEndlessMode && hasLivesRemaining) ||
                    (_isExternalLevel && bloc != null)) {
                  // Retry reusing the existing bloc — the only valid path for
                  // survival and external levels (community / editor test),
                  // which don't exist in the local catalog AppRoutes.gameFor
                  // would resolve.
                  bloc!.add(const RetryLevel());
                  context.pop();
                } else {
                  // Campaign or game over: replay the same level.
                  context.pushReplacement(AppRoutes.gameFor(result.levelId));
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
