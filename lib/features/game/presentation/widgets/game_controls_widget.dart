import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Undo + restart controls for the game screen.
class GameControlsWidget extends StatelessWidget {
  const GameControlsWidget({
    super.key,
    required this.canUndo,
    required this.onUndo,
    required this.onRestart,
  });

  final bool canUndo;
  final VoidCallback onUndo;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(
          icon: Icons.undo_rounded,
          label: 'Deshacer',
          onPressed: canUndo ? onUndo : null,
        ),
        const SizedBox(width: 16),
        _ControlButton(
          icon: Icons.refresh_rounded,
          label: 'Reiniciar',
          onPressed: onRestart,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.textDark,
        disabledBackgroundColor: AppColors.beige,
        disabledForegroundColor: AppColors.textMuted,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
