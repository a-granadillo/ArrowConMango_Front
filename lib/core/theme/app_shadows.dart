import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Shared drop-shadow presets for Arrow con Mango.
///
/// The playful look leans on solid, offset "sticker" shadows (no blur) plus a
/// couple of soft ambient ones. These were previously hardcoded per widget with
/// slightly different colors/offsets; centralizing them keeps depth consistent.
abstract final class AppShadows {
  /// Soft card outline shadow (cards, chips, undo pill, setting rows).
  static const List<BoxShadow> card = [
    BoxShadow(color: AppColors.border, offset: Offset(0, 3)),
  ];

  /// Slightly raised neutral card (unlocked level tile).
  static const List<BoxShadow> cardRaised = [
    BoxShadow(color: AppColors.shadowCard, offset: Offset(0, 4)),
  ];

  /// Muted shadow for disabled/locked surfaces.
  static const List<BoxShadow> locked = [
    BoxShadow(color: AppColors.stone, offset: Offset(0, 3)),
  ];

  /// Warm mango shadow (completed tile).
  static const List<BoxShadow> mango = [
    BoxShadow(color: AppColors.shadowMango, offset: Offset(0, 5)),
  ];

  /// Primary CTA on the brand gradient — sticker shadow plus a soft glow.
  static const List<BoxShadow> button = [
    BoxShadow(color: AppColors.shadowButton, offset: Offset(0, 6)),
    BoxShadow(
      color: Color(0x59F4843D),
      offset: Offset(0, 10),
      blurRadius: 28,
    ),
  ];

  /// Primary action button inside result sheets (deeper, no glow).
  static const List<BoxShadow> buttonStrong = [
    BoxShadow(color: AppColors.primaryButtonShadow, offset: Offset(0, 5)),
  ];

  /// A solid sticker shadow in an arbitrary tone + vertical offset.
  static List<BoxShadow> solid(Color color, {double dy = 5}) => [
        BoxShadow(color: color, offset: Offset(0, dy)),
      ];

  /// Ambient shadow under the floating mango logo.
  static const List<BoxShadow> float = [
    BoxShadow(color: Color(0x38000000), blurRadius: 20, offset: Offset(0, 10)),
  ];

  /// Upward ambient shadow for the result bottom sheet.
  static const List<BoxShadow> sheet = [
    BoxShadow(color: Color(0x406D4C2A), blurRadius: 40, offset: Offset(0, -8)),
  ];
}
