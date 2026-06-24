import 'package:flutter/material.dart';
import '../theme/mango_colors.dart';

/// Menú principal del juego
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Espaciador superior
              const Spacer(flex: 2),
              
              // Título del juego
              Text(
                'ArrowConMango',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: MangoColors.mangoOrange,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Subtítulo
              Text(
                'El Puzzle de las Flechas',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: MangoColors.textSecondary,
                ),
              ),
              
              const Spacer(flex: 3),
              
              // Botón Jugar
              _MenuButton(
                text: 'JUGAR',
                icon: Icons.play_arrow,
                color: MangoColors.mangoOrange,
                onPressed: () {
                  // TODO: Navegar a LevelSelectionScreen
                },
              ),
              
              const SizedBox(height: 16),
              
              // Botón Ajustes
              _MenuButton(
                text: 'AJUSTES',
                icon: Icons.settings,
                color: MangoColors.leafGreen,
                onPressed: () {
                  // TODO: Navegar a SettingsScreen
                },
              ),
              
              const SizedBox(height: 16),
              
              // Botón Créditos
              _MenuButton(
                text: 'CRÉDITOS',
                icon: Icons.info_outline,
                color: MangoColors.darkLeafGreen,
                onPressed: () {
                  // TODO: Mostrar diálogo de créditos
                },
              ),
              
              const Spacer(flex: 2),
              
              // Versión del juego
              Text(
                'v1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: MangoColors.textSecondary.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón reutilizable del menú principal
class _MenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: color.withOpacity(0.5),
        ),
      ),
    );
  }
}
