import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';

/// A single stat cell (value + label) used in [ResultStatsRow].
class ResultStat extends StatelessWidget {
  const ResultStat({
    super.key,
    required this.value,
    required this.label,
    this.color = AppColors.primary,
    this.showDivider = true,
  });

  final String value;
  final String label;
  final Color color;

  /// Whether to draw the vertical divider on this cell's trailing edge.
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: showDivider
            ? const BoxDecoration(
                border: Border(
                  right: BorderSide(color: AppColors.border, width: 1),
                ),
              )
            : null,
        child: Column(
          children: [
            Text(value, style: AppTypography.statValue(color: color)),
            const SizedBox(height: 2),
            Text(label, style: AppTypography.caption(weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// The design's result stats card: a cream-beige row of stat cells with
/// vertical dividers between them (none after the last cell).
class ResultStatsRow extends StatelessWidget {
  const ResultStatsRow({super.key, required this.stats});

  final List<ResultStat> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.cream2,
        borderRadius: AppRadii.mdAll,
      ),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++)
            _withDivider(stats[i], i < stats.length - 1),
        ],
      ),
    );
  }

  Widget _withDivider(ResultStat stat, bool showDivider) => ResultStat(
        value: stat.value,
        label: stat.label,
        color: stat.color,
        showDivider: showDivider,
      );
}

/// Formats [seconds] as `m:ss`.
String formatDuration(int seconds) {
  final m = seconds ~/ 60;
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
