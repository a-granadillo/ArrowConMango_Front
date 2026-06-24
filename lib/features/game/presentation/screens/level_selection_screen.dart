import 'package:flutter/material.dart';
import '../theme/mango_colors.dart';

/// Pantalla de selección de niveles
class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Nivel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: 15,
          itemBuilder: (context, index) {
            final levelNumber = index + 1;
            final isUnlocked = levelNumber <= 5;
            
            return _LevelCard(
              levelNumber: levelNumber,
              isUnlocked: isUnlocked,
              difficulty: _getDifficulty(levelNumber),
              onPressed: isUnlocked
                  ? () {
                      // TODO: Navegar a GameScreen con este nivel
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }

  String _getDifficulty(int level) {
    if (level <= 5) return 'Easy';
    if (level <= 10) return 'Medium';
    return 'Hard';
  }
}

/// Tarjeta individual de nivel
class _LevelCard extends StatelessWidget {
  final int levelNumber;
  final bool isUnlocked;
  final String difficulty;
  final VoidCallback? onPressed;

  const _LevelCard({
    required this.levelNumber,
    required this.isUnlocked,
    required this.difficulty,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isUnlocked
        ? MangoColors.mangoOrange
        : Colors.grey.shade400;
    
    final textColor = isUnlocked ? Colors.white : Colors.grey.shade600;

    return Card(
      elevation: isUnlocked ? 4 : 2,
      color: backgroundColor,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isUnlocked
                ? Border.all(color: MangoColors.mangoYellow, width: 2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono de candado o número de nivel
              if (isUnlocked)
                Text(
                  '$levelNumber',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Icon(
                  Icons.lock,
                  size: 32,
                  color: textColor,
                ),
              
              const SizedBox(height: 8),
              
              // Dificultad
              Text(
                difficulty,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
