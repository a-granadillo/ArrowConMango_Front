import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_svgs.dart';

/// Large call-to-action button used on the main menu and the "Jugar" hub.
///
/// When [bg] is set, pass an explicit [fg] to guarantee contrast — the
/// default text color only applies to the plain brand-gradient button.
class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.onTap,
    required this.label,
    this.bg,
    this.fg,
    this.shadow,
  });

  final VoidCallback onTap;
  final String label;
  final Color? bg;
  final Color? fg;
  final Color? shadow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          gradient: bg == null ? AppGradients.orange : null,
          borderRadius: AppRadii.pillAll,
          boxShadow: [
            BoxShadow(
              color: shadow ?? AppColors.shadowButton,
              offset: const Offset(0, 6),
            ),
            if (bg == null) ...AppShadows.button.sublist(1),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.display(
            26,
            color: fg ?? (bg != null ? AppColors.textDark : Colors.white),
          ).copyWith(letterSpacing: 2),
        ),
      ),
    );
  }
}

/// Small icon + label navigation button (Levels/Ranking/Settings row).
class NavButton extends StatelessWidget {
  const NavButton({
    super.key,
    required this.svg,
    required this.label,
    required this.bg,
    required this.fg,
    required this.shadow,
    required this.onTap,
  });

  final String svg;
  final String label;
  final Color bg;
  final Color fg;
  final Color shadow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadii.mdAll,
          boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSvgs.icon(svg, 22),
            const SizedBox(height: 5),
            Text(
              label,
              style: AppTypography.label(color: fg, weight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
