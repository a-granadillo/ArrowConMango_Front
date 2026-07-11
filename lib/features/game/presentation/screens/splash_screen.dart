import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mango_background.dart';

/// Loading / branding screen shown at launch. Auto-navigates to the main menu.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// How long the splash stays before navigating.
  static const Duration displayDuration = Duration(milliseconds: 1800);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashScreen.displayDuration, _goToMenu);
  }

  void _goToMenu() {
    if (mounted) context.go(AppRoutes.menu);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
              const Text('🥭', style: TextStyle(fontSize: 96)),
              const SizedBox(height: 16),
              Text(
                'ARROW CON MANGO',
                textAlign: TextAlign.center,
                style: AppTypography.display(
                  40,
                  color: AppColors.textOnPrimary,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¡El laberinto más sabroso!',
                textAlign: TextAlign.center,
                style: AppTypography.body(18, color: AppColors.textOnPrimary),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(color: AppColors.textOnPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
