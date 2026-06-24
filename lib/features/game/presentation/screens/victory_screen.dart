import 'package:flutter/material.dart';
import '../theme/mango_colors.dart';

/// Pantalla de victoria al completar un nivel
class VictoryScreen extends StatelessWidget {
  const VictoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: MangoColors.leafGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // Mensaje de victoria
                Text(
                  '¡VICTORIA!',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: const Offset(3, 3),
                        blurRadius: 5,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Subtítulo
                Text(
                  'Nivel Completado',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                
                const Spacer(flex: 1),
                
                // Estrellas de calificación
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StarIcon(isFilled: true),
                    _StarIcon(isFilled: true),
                    _StarIcon(isFilled: false),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Tarjeta de puntuación
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _ScoreRow(
                        icon: Icons.touch_app,
                        label: 'Movimientos',
                        value: '12',
                      ),
                      const Divider(height: 24),
                      _ScoreRow(
                        icon: Icons.timer,
                        label: 'Tiempo',
                        value: '01:23',
                      ),
                      const Divider(height: 24),
                      _ScoreRow(
                        icon: Icons.star,
                        label: 'Puntos',
                        value: '850',
                        isHighlighted: true,
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Botón Siguiente Nivel
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navegar al siguiente nivel
                    },
                    icon: const Icon(Icons.arrow_forward, size: 28),
                    label: const Text('SIGUIENTE NIVEL'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MangoColors.mangoOrange,
                      foregroundColor: Colors.white,
                      elevation: 4,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Botón Menú Principal
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Navegar al menú principal
                    },
                    icon: const Icon(Icons.home, size: 28),
                    label: const Text('MENÚ PRINCIPAL'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                ),
                
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ícono de estrella (llena o vacía)
class _StarIcon extends StatelessWidget {
  final bool isFilled;

  const _StarIcon({required this.isFilled});

  @override
  Widget build(BuildContext context) {
    return Icon(
      isFilled ? Icons.star : Icons.star_border,
      size: 48,
      color: isFilled ? MangoColors.mangoYellow : Colors.white.withOpacity(0.5),
    );
  }
}

/// Fila de puntuación (ícono, etiqueta, valor)
class _ScoreRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlighted;

  const _ScoreRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isHighlighted
        ? MangoColors.mangoOrange
        : MangoColors.textPrimary;
    
    return Row(
      children: [
        Icon(icon, color: textColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: textColor,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
