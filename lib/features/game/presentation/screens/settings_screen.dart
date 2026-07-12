import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_svgs.dart';
import '../../../../core/widgets/mango_logo.dart';
import '../../../player/domain/guest_player.dart';
import '../../../player/presentation/player_cubit.dart';

/// Settings screen — styled consistently with the design system.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _audioOn = true;
  String _language = 'es';

  Future<void> _editName(BuildContext context) async {
    final cubit = context.read<PlayerCubit>();
    final controller = TextEditingController(text: cubit.state.displayName);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nombre de jugador'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 20,
          decoration: const InputDecoration(hintText: 'Tu nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Guardar'),
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
                    title: 'Nombre de jugador',
                    subtitle: player.displayName,
                    trailing: TextButton(
                      onPressed: () => _editName(context),
                      child: const Text('Editar'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _SettingCard(
                  icon: Icons.volume_up_rounded,
                  title: 'Sonido',
                  trailing: Switch(
                    value: _audioOn,
                    activeThumbColor: AppColors.success,
                    onChanged: (v) => setState(() => _audioOn = v),
                  ),
                ),
                const SizedBox(height: 12),
                _SettingCard(
                  icon: Icons.language_rounded,
                  title: 'Idioma',
                  trailing: DropdownButton<String>(
                    value: _language,
                    underline: const SizedBox.shrink(),
                    onChanged: (v) => setState(() => _language = v ?? _language),
                    items: const [
                      DropdownMenuItem(value: 'es', child: Text('Español')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            onTap: () => context.pop(),
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
              'Ajustes',
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
        boxShadow: const [BoxShadow(color: Color(0xFFE8D5C0), offset: Offset(0, 3))],
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
