import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mango_logo.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  bool _showForm = false;
  bool _isRegister = false;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _userCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _userCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthGuest || state is AuthAuthenticated) {
          context.go(AppRoutes.menu);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FloatingMango(size: 80),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'ARROW CON MANGO',
                      textAlign: TextAlign.center,
                      style: AppTypography.display(28, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    if (!_showForm) ...[
                      _PrimaryButton(
                        label: 'Jugar como invitado',
                        onTap: () =>
                            context.read<AuthCubit>().continueAsGuest(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: () => setState(() => _showForm = true),
                        child: Text(
                          '¿Ya tenés cuenta? Iniciar sesión',
                          style: AppTypography.body(
                            14,
                            weight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ] else ...[
                      _buildForm(context),
                    ],
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const Padding(
                            padding: EdgeInsets.only(top: AppSpacing.md),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        }
                        if (state is AuthFailure) {
                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.md),
                            child: Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: AppTypography.body(
                                14,
                                weight: FontWeight.w600,
                                color: AppColors.danger,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isRegister) ...[
          _InputField(
            controller: _userCtrl,
            label: 'Nombre de usuario',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        _InputField(
          controller: _emailCtrl,
          label: 'Correo electrónico',
          icon: Icons.email_outlined,
          keyboard: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppSpacing.sm),
        _InputField(
          controller: _passCtrl,
          label: 'Contraseña',
          icon: Icons.lock_outline,
          obscure: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        _PrimaryButton(
          label: _isRegister ? 'Registrarse' : 'Iniciar sesión',
          onTap: () {
            final cubit = context.read<AuthCubit>();
            if (_isRegister) {
              cubit.register(
                email: _emailCtrl.text.trim(),
                password: _passCtrl.text,
                username: _userCtrl.text.trim(),
              );
            } else {
              cubit.login(
                email: _emailCtrl.text.trim(),
                password: _passCtrl.text,
              );
            }
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () => setState(() => _isRegister = !_isRegister),
          child: Text(
            _isRegister
                ? '¿Ya tenés cuenta? Iniciar sesión'
                : '¿No tenés cuenta? Registrate',
            style: AppTypography.body(
              13,
              weight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          onPressed: () => setState(() => _showForm = false),
          child: Text(
            'Volver',
            style: AppTypography.body(
              13,
              weight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          gradient: AppGradients.orange,
          borderRadius: AppRadii.mdAll,
          boxShadow: AppShadows.buttonStrong,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.display(20, color: Colors.white),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboard = TextInputType.text,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboard;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      style: AppTypography.body(15),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        hintText: label,
        hintStyle: AppTypography.body(15, color: AppColors.textMuted),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
