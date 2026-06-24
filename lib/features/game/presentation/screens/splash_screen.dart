import 'package:flutter/material.dart';
import '../theme/mango_colors.dart';

/// Pantalla de carga inicial con logo de ArrowConMango
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: MangoColors.mangoGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Título principal
              Text(
                'ArrowConMango',
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
              
              const SizedBox(height: 40),
              
              // Subtítulo
              Text(
                'El Puzzle de las Flechas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              
              const SizedBox(height: 80),
              
              // Indicador de carga
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
              
              const SizedBox(height: 20),
              
              // Texto de carga
              Text(
                'Cargando...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
