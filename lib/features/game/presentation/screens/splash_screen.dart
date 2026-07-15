import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/audio_track.dart';
import '../../../../core/i18n/app_localizations_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
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
    context.go(AppRoutes.menu);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _goToMenu,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.brand),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FloatingMango(size: 120, leaf: AppColors.mango),
                const SizedBox(height: 16),
                Text(
                  'ARROW CON',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 38,
                    height: 1.05,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'MANGO',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 46,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  context.l10n.splashTapToContinue,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
