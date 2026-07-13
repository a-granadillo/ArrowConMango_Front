import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/result_sheet.dart';
import '../widgets/result_stat.dart';

/// Defeat screen: explains why the level was lost and offers a retry.
///
/// The source design has no defeat/lose dialog to reproduce — this reuses
/// the same [ResultSheet] chrome as the victory screen (bottom sheet, drag
/// handle, stats card, button language) so it reads as part of the same
/// system rather than an ad-hoc screen.
class DefeatScreen extends StatelessWidget {
  const DefeatScreen({super.key, required this.result, this.bloc});

  final GameDefeat result;
  final GameBloc? bloc;

  String get _reasonText => switch (result.reason) {
        DefeatReason.timeExpired => '¡Se acabó el tiempo!',
        DefeatReason.noMovesAvailable => 'No quedan movimientos posibles.',
        DefeatReason.outOfLives => '¡Te quedaste sin vidas!',
      };

  @override
  Widget build(BuildContext context) {
    final hasLivesRemaining = result.livesRemaining > 0;
    final isGameOver = result.isEndlessMode && !hasLivesRemaining;
    
    return Scaffold(
      body: ResultSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isGameOver ? '💀' : '😵', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 10),
            Text(
              isGameOver ? '¡Game Over!' : '¡Oh no!',
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
              isGameOver ? 'Te quedaste sin vidas' : _reasonText,
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
                if (result.isEndlessMode) ...[
                  ResultStat(
                    value: '${result.levelsCompleted}',
                    label: 'Niveles',
                    color: AppColors.primary,
                  ),
                  ResultStat(
                    value: '${result.livesRemaining}',
                    label: 'Vidas',
                    color: AppColors.danger,
                    showDivider: false,
                  ),
                ] else ...[
                  ResultStat(
                    value: '${result.moveCount}',
                    label: 'Toques',
                    color: AppColors.primary,
                  ),
                  ResultStat(
                    value: formatDuration(result.elapsedSeconds),
                    label: 'Tiempo',
                    color: AppColors.success,
                    showDivider: false,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go(AppRoutes.menu),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.cream2,
                      foregroundColor: AppColors.textMuted,
                      side: const BorderSide(color: Color(0xFFE8D5C0), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Menú'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      if (result.isEndlessMode && hasLivesRemaining) {
                        // En modo supervivencia con vidas restantes, reintentar reusando el bloc
                        if (bloc != null) {
                          bloc!.add(const RetryLevel());
                          context.pop();
                        } else {
                          final nextLevelId = -(DateTime.now().millisecondsSinceEpoch % 10000 + 1);
                          context.pushReplacement(AppRoutes.gameFor(nextLevelId));
                        }
                      } else {
                        // En modo campaña o game over, reintentar el mismo nivel
                        context.pushReplacement(
                          AppRoutes.gameFor(result.levelId),
                        );
                      }
                    },
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
                        isGameOver ? 'Reiniciar' : 'Reintentar',
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
            ),
          ],
        ),
      ),
    );
  }
}
