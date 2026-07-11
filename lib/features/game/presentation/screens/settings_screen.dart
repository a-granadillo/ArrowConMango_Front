import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mango_background.dart';
import '../../../player/domain/guest_player.dart';
import '../../../player/presentation/player_cubit.dart';

/// App settings: guest name, audio and language.
///
/// Audio (#6) and language (#15) are visual stubs for now; the guest-name
/// editor is fully wired through [PlayerCubit].
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
    return MangoBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textOnPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Ajustes',
                style:
                    AppTypography.display(26, color: AppColors.textOnPrimary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  BlocBuilder<PlayerCubit, GuestPlayer>(
                    builder: (context, player) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person_rounded,
                          color: AppColors.primary),
                      title: const Text('Nombre de jugador'),
                      subtitle: Text(player.displayName),
                      trailing: TextButton(
                        onPressed: () => _editName(context),
                        child: const Text('Editar'),
                      ),
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.volume_up_rounded,
                        color: AppColors.primary),
                    title: const Text('Sonido'),
                    value: _audioOn,
                    onChanged: (v) => setState(() => _audioOn = v),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.language_rounded,
                        color: AppColors.primary),
                    title: const Text('Idioma'),
                    trailing: DropdownButton<String>(
                      value: _language,
                      onChanged: (v) =>
                          setState(() => _language = v ?? _language),
                      items: const [
                        DropdownMenuItem(value: 'es', child: Text('Español')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
