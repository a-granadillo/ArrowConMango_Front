import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_svgs.dart';

/// Undo control for the game screen.
///
/// Restart lives in the header (matching the design's icon layout); the
/// design itself has no undo affordance, so this small pill extends it
/// consistently with the app's visual language, shown only while a move
/// can be undone.
class GameControlsWidget extends StatelessWidget {
  const GameControlsWidget({
    super.key,
    required this.canUndo,
    required this.onUndo,
  });

  final bool canUndo;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    if (!canUndo) return const SizedBox(height: 40);
    return GestureDetector(
      onTap: onUndo,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0xFFE8D5C0), offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSvgs.icon(AppSvgs.undo, 16),
            const SizedBox(width: 6),
            Text(
              'Deshacer',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
