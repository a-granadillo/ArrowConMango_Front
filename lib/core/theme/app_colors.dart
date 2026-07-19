import 'package:flutter/material.dart';

/// Brand color palette for Arrow con Mango.
///
/// Values are extracted from the approved UI mockup. Colors live in the
/// presentation layer only — the domain never references them.
abstract final class AppColors {
  // --- Brand (mango / orange) ---
  /// Primary brand orange (backgrounds, primary surfaces).
  static const Color primary = Color(0xFFF4843D);

  /// Darker orange used as the end stop of the brand gradient.
  static const Color primaryDark = Color(0xFFE0601C);

  /// Mango yellow — secondary accent, buttons, highlights.
  static const Color mango = Color(0xFFF9C74F);

  // --- Semantic ---
  /// Success / victory green.
  static const Color success = Color(0xFF4CAF50);

  /// Darker success green (gradient end).
  static const Color successDark = Color(0xFF2E7D32);

  /// Danger / defeat / error red.
  static const Color danger = Color(0xFFE85D5D);

  // --- Text ---
  /// Primary text (warm brown).
  static const Color textDark = Color(0xFF6D4C2A);

  /// Muted / secondary text.
  static const Color textMuted = Color(0xFFA0826D);

  /// Text drawn on top of dark/brand surfaces.
  static const Color textOnPrimary = Color(0xFFFFF8EE);

  // --- Surfaces ---
  /// Lightest cream surface.
  static const Color cream = Color(0xFFFFF8EE);

  /// Secondary cream.
  static const Color cream2 = Color(0xFFFFF0D4);

  /// Beige surface / board cells. Also the app's hairline border/divider color
  /// (previously hardcoded as `0xFFE8D5C0` in ~6 places).
  static const Color beige = Color(0xFFE8D5C0);

  /// Muted border/divider (alias of [beige]) for card outlines and dividers.
  static const Color border = beige;

  /// Locked / disabled surface (level tiles).
  static const Color lockedSurface = Color(0xFFEDE0D4);

  /// Muted stone used for "N/3 MANGOS" labels and locked-tile shadows.
  static const Color stone = Color(0xFFC5B8A5);

  // --- Chrome accents ---
  /// Unified brand gold (previously two competing values `0xFFD4A017` /
  /// `0xFFB8860B` for the same mango button).
  static const Color gold = Color(0xFFD4A017);

  /// Deep espresso brown for high-contrast button shadows.
  static const Color espresso = Color(0xFF3E2723);

  /// Warm mid orange — end stop of the in-game header gradient.
  static const Color headerOrangeEnd = Color(0xFFF9A84D);

  /// Primary action-button gradient end + its drop shadow.
  static const Color primaryButtonEnd = Color(0xFFD85E18);
  static const Color primaryButtonShadow = Color(0xFFA83800);

  // --- Shadow tones (opaque; wrapped in BoxShadow by AppShadows) ---
  /// Neutral card drop shadow.
  static const Color shadowCard = Color(0xFFD4C4B0);
  /// Warm button drop shadow.
  static const Color shadowButton = Color(0xFFB03800);
  /// Mango/completed-tile drop shadow.
  static const Color shadowMango = Color(0xFFC87010);

  // --- Difficulty accents ---
  /// Easy levels.
  static const Color difficultyEasy = Color(0xFF8BC34A);

  /// Medium levels.
  static const Color difficultyMedium = Color(0xFF57A0C7);

  /// Hard levels.
  static const Color difficultyHard = Color(0xFF9B6BC7);

  /// Returns the accent color for a difficulty label ("Easy"/"Medium"/"Hard").
  static Color forDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return difficultyEasy;
      case 'medium':
        return difficultyMedium;
      case 'hard':
        return difficultyHard;
      default:
        return primary;
    }
  }
}
