import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_svgs.dart';
import '../../../../core/widgets/mango_logo.dart';

/// Main menu ("Home") — faithful reproduction of the design.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: LayoutBuilder(
        builder: (context, c) {
          final headerH = c.maxHeight * 0.44;
          return Stack(
            children: [
              // Curved green header with faded leaves.
              _GreenHeader(height: headerH, width: c.maxWidth),
              // Foreground content.
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 42),
                    const FloatingMango(size: 112),
                    const SizedBox(height: 14),
                    Text(
                      'ARROW CON',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 44,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'MANGO',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 50,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '¡EL LABERINTO MÁS SABROSO!',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          _PlayButton(
                            label: 'MODO CAMPAÑA',
                            onTap: () => context.push(AppRoutes.levels),
                          ),
                          const SizedBox(height: 14),
                          _PlayButton(
                            label: 'SUPERVIVENCIA',
                            bg: AppColors.textDark,
                            shadow: const Color(0xFF3E2723),
                            onTap: () {
                              // TODO: Connect to Endless mode logic via BLoC / Router
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Modo Supervivencia pronto disponible')),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _NavButton(
                                  svg: AppSvgs.niveles,
                                  label: 'Niveles',
                                  bg: AppColors.mango,
                                  fg: AppColors.textDark,
                                  shadow: const Color(0xFFD4A017),
                                  onTap: () => context.push(AppRoutes.levels),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _NavButton(
                                  svg: AppSvgs.ranking,
                                  label: 'Ranking',
                                  bg: AppColors.success,
                                  fg: Colors.white,
                                  shadow: AppColors.successDark,
                                  onTap: () => context.push(AppRoutes.ranking),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _NavButton(
                                  svg: AppSvgs.ajustes,
                                  label: 'Ajustes',
                                  bg: AppColors.textDark,
                                  fg: AppColors.mango,
                                  shadow: const Color(0xFF3E2723),
                                  onTap: () => context.push(AppRoutes.settings),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _PageDots(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GreenHeader extends StatelessWidget {
  const _GreenHeader({required this.height, required this.width});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.4, -1),
          end: Alignment(0.4, 1),
          colors: [AppColors.successDark, AppColors.success],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.elliptical(width * 0.6, 72),
          bottomRight: Radius.elliptical(width * 0.6, 72),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.elliptical(width * 0.6, 72),
          bottomRight: Radius.elliptical(width * 0.6, 72),
        ),
        child: Opacity(
          opacity: 0.14,
          child: Stack(
            children: [
              _leaf(width * 0.08, height * 0.16, 22, -30),
              _leaf(width * 0.26, height * 0.38, 38, -10),
              _leaf(width * 0.52, height * 0.58, 22, 10),
              _leaf(width * 0.70, height * 0.16, 38, 25),
              _leaf(width * 0.88, height * 0.38, 22, 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leaf(double left, double top, double size, double deg) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: deg * 3.14159 / 180,
        child: SvgPicture.string(AppSvgs.leaf, width: size, height: size),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.onTap,
    required this.label,
    this.bg,
    this.shadow,
  });

  final VoidCallback onTap;
  final String label;
  final Color? bg;
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
            color: bg != null ? AppColors.mango : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
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

class _PageDots extends StatelessWidget {
  const _PageDots();

  @override
  Widget build(BuildContext context) {
    Widget dot(double w, Color color, [double opacity = 1]) => Opacity(
          opacity: opacity,
          child: Container(
            width: w,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        dot(8, AppColors.mango, 0.5),
        const SizedBox(width: 6),
        dot(8, AppColors.primary, 0.5),
        const SizedBox(width: 6),
        dot(22, AppColors.success),
        const SizedBox(width: 6),
        dot(8, AppColors.primary, 0.5),
        const SizedBox(width: 6),
        dot(8, AppColors.mango, 0.5),
      ],
    );
  }
}
