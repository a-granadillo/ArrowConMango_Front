import 'package:flutter/material.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_svgs.dart';

/// Translucent icon + value (+ optional label) chip shown in the in-game
/// header HUD. A single shared implementation replacing the `_StatChip`
/// copies that lived in the 2D / hex / 3D game screens.
class StatChip extends StatelessWidget {
  const StatChip({
    super.key,
    required this.svg,
    required this.value,
    this.label = '',
  });

  final String svg;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: AppRadii.smAll,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgs.icon(svg, 15),
          const SizedBox(width: 6),
          Text(
            value,
            style: AppTypography.display(20, color: Colors.white),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.xxs),
            Text(
              label,
              style: AppTypography.caption(
                color: Colors.white.withValues(alpha: 0.75),
                weight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
