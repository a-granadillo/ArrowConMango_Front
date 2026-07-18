import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/audio_settings_cubit.dart';
import '../../../../core/audio/audio_settings_state.dart';
import '../../../../core/audio/sfx_clip.dart';
import '../../../../core/i18n/app_localizations_extension.dart';
import '../../../../core/i18n/locale_cubit.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/mango_logo.dart';
import '../../../player/domain/guest_player.dart';
import '../../../player/presentation/bloc/auth_cubit.dart';
import '../../../player/presentation/player_cubit.dart';

/// Settings screen — styled consistently with the design system.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Locale _language = const Locale('es');
  AudioService? _audioService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _audioService ??= context.read<AudioService>();
    _language = context.read<LocaleCubit>().state;
  }

  VoidCallback _withClick(VoidCallback action) => () {
    _audioService?.playSfx(SfxClip.click);
    action();
  };

  Future<void> _editName(BuildContext context) async {
    final cubit = context.read<PlayerCubit>();
    final controller = TextEditingController(text: cubit.state.displayName);
    final l10n = context.l10n;
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsDialogPlayerName),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 20,
          decoration: InputDecoration(hintText: l10n.settingsDialogHint),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _audioService?.playSfx(SfxClip.click);
              Navigator.of(dialogContext).pop();
            },
            child: Text(l10n.settingsDialogCancel),
          ),
          TextButton(
            onPressed: () {
              _audioService?.playSfx(SfxClip.click);
              Navigator.of(dialogContext).pop(controller.text.trim());
            },
            child: Text(l10n.settingsDialogSave),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      await cubit.rename(newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppScreenHeader(
            title: context.l10n.settingsTitle,
            onBack: _withClick(() => context.pop()),
            trailing: const MangoLogo(size: 36, leaf: AppColors.mango),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.maxContentWidth,
                ),
                child: ListView(
                  padding: AppSpacing.page,
                  children: [
                    BlocBuilder<PlayerCubit, GuestPlayer>(
                      builder: (context, player) => _SettingCard(
                        icon: Icons.person_rounded,
                        title: context.l10n.settingsPlayerName,
                        subtitle: player.displayName,
                        trailing: TextButton(
                          onPressed: _withClick(() => _editName(context)),
                          child: Text(context.l10n.settingsEdit),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SettingCard(
                      icon: Icons.volume_up_rounded,
                      title: context.l10n.settingsSound,
                      trailing:
                          BlocBuilder<AudioSettingsCubit, AudioSettingsState>(
                        builder: (context, audioState) => Switch(
                          value: !audioState.isMuted,
                          activeThumbColor: AppColors.success,
                          onChanged: (_) =>
                              context.read<AudioSettingsCubit>().toggleMute(),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SettingCard(
                      icon: Icons.language_rounded,
                      title: context.l10n.settingsLanguage,
                      trailing: DropdownButton<Locale>(
                        value: _language,
                        underline: const SizedBox.shrink(),
                        onChanged: (locale) {
                          if (locale == null) return;
                          setState(() => _language = locale);
                          context.read<LocaleCubit>().setLocale(locale);
                        },
                        items: const [
                          DropdownMenuItem(
                            value: Locale('es'),
                            child: Text('Español'),
                          ),
                          DropdownMenuItem(
                            value: Locale('en'),
                            child: Text('English'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppCard(
                      onTap: _withClick(() async {
                        await context.read<AuthCubit>().signOut();
                        if (context.mounted) {
                          context.go(AppRoutes.auth);
                        }
                      }),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            color: AppColors.danger,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Cerrar sesión',
                            style: AppTypography.body(
                              15,
                              weight: FontWeight.w700,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body(15, weight: FontWeight.w700),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.body(13, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
