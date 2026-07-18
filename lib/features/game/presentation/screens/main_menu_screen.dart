import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/audio_track.dart';
import '../../../../core/audio/sfx_clip.dart';
import '../../../../core/i18n/app_localizations_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_svgs.dart';
import '../../../../core/widgets/mango_logo.dart';
import '../widgets/menu_buttons.dart';

/// Main menu ("Home") — faithful reproduction of the design.
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  AudioService? _audioService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _audioService ??= context.read<AudioService>();
    _audioService!.playBgm(AudioTrack.menuTheme);
  }

  VoidCallback _withClick(VoidCallback action) => () {
    _audioService?.playSfx(SfxClip.click);
    action();
  };

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
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: c.maxHeight - 40),
                    child: IntrinsicHeight(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: AppSpacing.maxContentWidth,
                          ),
                          child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.xl),
                          const FloatingMango(size: 112),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'ARROW CON',
                            textAlign: TextAlign.center,
                            style: AppTypography.display(
                              44,
                              weight: FontWeight.w700,
                            ).copyWith(height: 1.05),
                          ),
                          Text(
                            'MANGO',
                            textAlign: TextAlign.center,
                            style: AppTypography.display(
                              50,
                              weight: FontWeight.w700,
                              color: AppColors.primary,
                            ).copyWith(height: 1, letterSpacing: 1),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            context.l10n.menuSubtitle,
                            style: AppTypography.label(
                              weight: FontWeight.w700,
                            ).copyWith(letterSpacing: 2.5),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                            ),
                            child: Column(
                              children: [
                                PlayButton(
                                  label: context.l10n.menuPlay,
                                  onTap: _withClick(
                                    () => context.push(AppRoutes.playHub),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                PlayButton(
                                  label: 'MODO CREATIVO',
                                  bg: AppColors.mango,
                                  fg: AppColors.textDark,
                                  shadow: AppColors.gold,
                                  onTap: _withClick(
                                    () => context.push(AppRoutes.creativeHub),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Expanded(
                                      child: NavButton(
                                        svg: AppSvgs.niveles,
                                        label: context.l10n.menuLevels,
                                        bg: AppColors.mango,
                                        fg: AppColors.textDark,
                                        shadow: AppColors.gold,
                                        onTap: _withClick(
                                          () => context.push(AppRoutes.levels),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: NavButton(
                                        svg: AppSvgs.ranking,
                                        label: context.l10n.menuRanking,
                                        bg: AppColors.success,
                                        fg: Colors.white,
                                        shadow: AppColors.successDark,
                                        onTap: _withClick(
                                          () => context.push(AppRoutes.ranking),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: NavButton(
                                        svg: AppSvgs.ajustes,
                                        label: context.l10n.menuSettings,
                                        bg: AppColors.textDark,
                                        fg: AppColors.mango,
                                        shadow: AppColors.espresso,
                                        onTap: _withClick(
                                          () => context.push(AppRoutes.settings),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const _PageDots(),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                          ),
                        ),
                      ),
                    ),
                  ),
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
