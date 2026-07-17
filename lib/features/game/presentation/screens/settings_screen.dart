import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/audio_settings_cubit.dart';
import '../../../../core/audio/audio_settings_state.dart';
import '../../../../core/audio/sfx_clip.dart';
import '../../../../core/i18n/app_localizations_extension.dart';
import '../../../../core/i18n/locale_cubit.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_svgs.dart';
import '../../../../core/widgets/mango_logo.dart';
import '../../../player/data/session_store.dart';
import '../../../player/domain/guest_player.dart';
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
          _Header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 12),
                _SettingCard(
                  icon: Icons.volume_up_rounded,
                  title: context.l10n.settingsSound,
                  trailing: BlocBuilder<AudioSettingsCubit, AudioSettingsState>(
                    builder: (context, audioState) => Switch(
                      value: !audioState.isMuted,
                      activeThumbColor: AppColors.success,
                      onChanged: (_) =>
                          context.read<AudioSettingsCubit>().toggleMute(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
                const _AccountCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows whether the player is a guest or logged-in, and lets them sign out
/// or reach the auth gate to create an account/sign in.
///
/// Listens to [SessionStore] directly (it's a [ChangeNotifier], not a BLoC)
/// since signing out elsewhere — e.g. an expired token forcing a logout via
/// [AuthInterceptor] — must be reflected here without a manual refresh.
class _AccountCard extends StatelessWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context) {
    final sessionStore = context.read<SessionStore>();
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: sessionStore,
      builder: (context, _) {
        final isAuthenticated = sessionStore.mode == SessionMode.authenticated;
        return _SettingCard(
          icon: Icons.account_circle_rounded,
          title: l10n.settingsAccount,
          subtitle: isAuthenticated
              ? l10n.settingsSignedInAs(
                  context.watch<PlayerCubit>().state.displayName,
                )
              : l10n.settingsPlayingAsGuest,
          trailing: TextButton(
            onPressed: () => isAuthenticated
                ? sessionStore.signOut()
                : context.push(AppRoutes.authGate),
            child: Text(
              isAuthenticated ? l10n.settingsSignOut : l10n.settingsSignIn,
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 20, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.4, -1),
          end: Alignment(0.4, 1),
          colors: [AppColors.successDark, AppColors.success],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.read<AudioService>().playSfx(SfxClip.click);
              context.pop();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppSvgs.icon(AppSvgs.backChevron, 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.settingsTitle,
              style: GoogleFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const MangoLogo(size: 36, leaf: AppColors.mango),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0xFFE8D5C0), offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
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
