import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// A single stat tile (icon + value + label) used on the result screens.
class ResultStat extends StatelessWidget {
  const ResultStat({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.display(24, color: AppColors.textDark)),
        Text(
          label,
          style: AppTypography.body(13, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

/// Formats [seconds] as `m:ss`.
String formatDuration(int seconds) {
  final m = seconds ~/ 60;
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
