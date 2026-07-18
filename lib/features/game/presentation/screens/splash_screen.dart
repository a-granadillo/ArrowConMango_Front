import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/audio_track.dart';
import '../../../../core/i18n/app_localizations_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mango_background.dart';
import '../../../../core/widgets/mango_logo.dart';

/// Brief branded loading screen, then navigates to the main menu.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const Duration displayDuration = Duration(milliseconds: 1800);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _goToMenu() {
    if (!mounted) return;
    context.read<AudioService>().playBgm(AudioTrack.menuTheme);
    context.go(AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _goToMenu,
      child: MangoBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FloatingMango(size: 120, leaf: AppColors.mango),
              const SizedBox(height: AppSpacing.md),
              Text(
                'ARROW CON',
                textAlign: TextAlign.center,
                style: AppTypography.display(
                  38,
                  weight: FontWeight.w700,
                ).copyWith(height: 1.05),
              ),
              Text(
                'MANGO',
                textAlign: TextAlign.center,
                style: AppTypography.display(
                  46,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ).copyWith(height: 1, letterSpacing: 1),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                context.l10n.splashTapToContinue,
                style: AppTypography.body(
                  14,
                  color: AppColors.textOnPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
