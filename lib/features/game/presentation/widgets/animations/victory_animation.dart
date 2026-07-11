import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Overlays a one-shot confetti burst on top of [child], played on mount.
class VictoryAnimation extends StatefulWidget {
  const VictoryAnimation({super.key, required this.child});

  final Widget child;

  @override
  State<VictoryAnimation> createState() => _VictoryAnimationState();
}

class _VictoryAnimationState extends State<VictoryAnimation> {
  late final ConfettiController _controller =
      ConfettiController(duration: const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        widget.child,
        ConfettiWidget(
          confettiController: _controller,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          maxBlastForce: 20,
          minBlastForce: 8,
          emissionFrequency: 0.05,
          numberOfParticles: 20,
          gravity: 0.25,
          colors: const [
            AppColors.mango,
            AppColors.primary,
            AppColors.success,
            AppColors.difficultyMedium,
            AppColors.difficultyHard,
          ],
          createParticlePath: (size) {
            // Simple round confetti.
            final path = Path();
            path.addOval(
              Rect.fromCircle(center: Offset.zero, radius: max(2, size.width / 2)),
            );
            return path;
          },
        ),
      ],
    );
  }
}
