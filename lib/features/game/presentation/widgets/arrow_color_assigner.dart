import 'package:flutter/painting.dart';

import '../../../../core/theme/app_colors.dart';

/// Assigns a stable color to each arrow id, in first-seen order.
///
/// The old code colored by the arrow's index in the *live* list, so when one
/// arrow exited, the rest shifted index and visibly changed color. Here a color
/// is assigned once per id and never reassigned, so colors stay put for the
/// whole level. First-seen order == the level's initial arrow order (the first
/// `GamePlaying` carries the full list), matching the design's palette order.
class ArrowColorAssigner {
  ArrowColorAssigner();

  /// Arrow palette in the design's order (mango, red, orange, green, blue,
  /// purple, light-green).
  static const List<Color> palette = [
    AppColors.mango,
    AppColors.danger,
    AppColors.primary,
    AppColors.success,
    AppColors.difficultyMedium,
    AppColors.difficultyHard,
    AppColors.difficultyEasy,
  ];

  final Map<String, Color> _byId = {};

  Color colorOf(String id) =>
      _byId.putIfAbsent(id, () => palette[_byId.length % palette.length]);

  /// Clears assignments (call when a new level loads).
  void reset() => _byId.clear();
}
