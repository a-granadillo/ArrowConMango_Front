import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
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
          gradient: bg == null
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary, AppColors.primaryDark],
                )
              : null,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: shadow ?? const Color(0xFFB03800),
              offset: const Offset(0, 6),
            ),
            if (bg == null)
              const BoxShadow(
                color: Color(0x59F4843D),
                offset: Offset(0, 10),
                blurRadius: 28,
              ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.fredoka(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: fg ?? (bg != null ? AppColors.textDark : Colors.white),
          ),
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
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSvgs.icon(svg, 22),
            const SizedBox(height: 5),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
