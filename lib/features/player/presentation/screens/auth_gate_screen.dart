import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/i18n/app_localizations_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mango_logo.dart';
import '../../../game/presentation/widgets/menu_buttons.dart';
import '../bloc/auth_cubit.dart';

/// First screen a fresh install sees: choose "Crear Cuenta", "Iniciar
/// Sesión", or "Jugar como Invitado".
///
/// Existing installs that already have a session (guest or authenticated)
/// never see this screen — the splash screen skips straight to the menu.
/// See `splash_screen.dart` and `app_router.dart`'s redirect.
class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FloatingMango(size: 100, leaf: AppColors.mango),
              const SizedBox(height: 20),
              Text(
                l10n.authGateTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.authGateSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 40),
              PlayButton(
                label: l10n.authGateCreateAccount,
                onTap: () => context.push(AppRoutes.authRegister),
              ),
              const SizedBox(height: 16),
              PlayButton(
                label: l10n.authGateSignIn,
                bg: Colors.white,
                fg: AppColors.textDark,
                shadow: AppColors.beige,
                onTap: () => context.push(AppRoutes.authLogin),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  context.read<AuthCubit>().continueAsGuest();
                  context.go(AppRoutes.menu);
                },
                child: Text(
                  l10n.authGatePlayAsGuest,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
