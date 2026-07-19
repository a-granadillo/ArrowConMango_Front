import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';

/// Faithful reproduction of the design's result-dialog chrome: a dark
/// translucent backdrop behind a bottom sheet that slides up with a drag
/// handle, rounded top corners and a lifted shadow.
///
/// The design shows this as a modal over the (blurred) game screen; since
/// navigation here replaces the game route, the backdrop is rendered as a
/// solid full-screen scrim instead of a real blur-over-content effect.
class ResultSheet extends StatefulWidget {
  const ResultSheet({super.key, required this.child, this.confetti = false});

  final Widget child;

  /// Whether to play the falling-confetti celebration over the sheet.
  final bool confetti;

  @override
  State<ResultSheet> createState() => _ResultSheetState();
}

class _ResultSheetState extends State<ResultSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  )..forward();
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
  );

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.textDark,
      child: Stack(
        children: [
          if (widget.confetti)
            const Positioned.fill(
              child: IgnorePointer(child: ConfettiRain()),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slide,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  14,
                  AppSpacing.xl,
                  40,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: AppRadii.sheetTop,
                  boxShadow: AppShadows.sheet,
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppColors.shadowCard,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      widget.child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Falling confetti, matching the design's `confettiFall` keyframe: each
/// particle translates down and rotates 720° while fading out, staggered
/// by a per-particle delay.
class ConfettiRain extends StatefulWidget {
  const ConfettiRain({super.key});

  @override
  State<ConfettiRain> createState() => _ConfettiRainState();
}

class _ConfettiRainState extends State<ConfettiRain>
    with SingleTickerProviderStateMixin {
  static const _colors = [
    AppColors.mango,
    AppColors.primary,
    AppColors.success,
    AppColors.danger,
    AppColors.difficultyHard,
    AppColors.difficultyMedium,
  ];
  static const _particleCount = 46;
  static const _totalMs = 2600;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _totalMs),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: _ConfettiPainter(
          elapsedMs: _controller.value * _totalMs,
          colors: _colors,
          count: _particleCount,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({
    required this.elapsedMs,
    required this.colors,
    required this.count,
  });

  final double elapsedMs;
  final List<Color> colors;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < count; i++) {
      final leftFraction = (i * 2.19) % 100 / 100;
      final delayMs = (i * 33) % 700;
      final durationMs = 1100 + (i % 5) * 200;
      final local = elapsedMs - delayMs;
      if (local <= 0 || local >= durationMs) continue;

      final t = local / durationMs;
      final dx = leftFraction * size.width;
      final dy = t * size.height * 1.05;
      final angle = t * 720 * 3.14159 / 180;
      final particleSize = 6.0 + (i % 4) * 1.5;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(angle);
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 1 - t);
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particleSize,
        height: particleSize,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(particleSize * 0.25)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.elapsedMs != elapsedMs;
}
