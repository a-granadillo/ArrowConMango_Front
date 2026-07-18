import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Brand typography for Arrow con Mango.
///
/// Display / headings use **Fredoka** (rounded, playful); body copy uses
/// **Nunito**. Both come from `google_fonts`.
abstract final class AppTypography {
  /// Rounded display font for titles and big numbers.
  static TextStyle display(double size, {Color? color, FontWeight? weight}) {
    return GoogleFonts.fredoka(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w600,
      color: color ?? AppColors.textDark,
    );
  }

  /// Body font.
  static TextStyle body(double size, {Color? color, FontWeight? weight}) {
    return GoogleFonts.nunito(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w600,
      color: color ?? AppColors.textDark,
    );
  }

  // --- Semantic scale --------------------------------------------------
  // Named styles so screens stop hardcoding `GoogleFonts.fredoka(fontSize: …)`
  // with drifting values (headers 17 vs 19, victory 32 vs 36, etc.).

  /// Large result / celebration titles (¡NIVEL COMPLETO!, ¡CUBO DESPEJADO!).
  static TextStyle titleLg({Color? color}) => GoogleFonts.fredoka(
        fontSize: 36,
        height: 1,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: color ?? AppColors.primary,
      );

  /// Section / screen-header titles (level selection, settings, leaderboard).
  static TextStyle titleMd({Color? color}) => GoogleFonts.fredoka(
        fontSize: 22,
        height: 1.1,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textDark,
      );

  /// Compact in-game header titles (2D/hex/3D — unified at 19).
  static TextStyle headline({Color? color}) => GoogleFonts.fredoka(
        fontSize: 19,
        height: 1.1,
        fontWeight: FontWeight.w600,
        color: color ?? Colors.white,
      );

  /// Big numeric stat values (taps / time / mangos).
  static TextStyle statValue({Color? color}) => GoogleFonts.fredoka(
        fontSize: 26,
        height: 1,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.primary,
      );

  /// Standard body copy / row titles.
  static TextStyle bodyText({Color? color, FontWeight? weight}) =>
      GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: weight ?? FontWeight.w700,
        color: color ?? AppColors.textDark,
      );

  /// Small labels (chip labels, subtitles).
  static TextStyle label({Color? color, FontWeight? weight}) =>
      GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? AppColors.textMuted,
      );

  /// Smallest captions (difficulty tags, meta counts).
  static TextStyle caption({Color? color, FontWeight? weight}) =>
      GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: weight ?? FontWeight.w700,
        color: color ?? AppColors.textMuted,
      );

  /// Full text theme wired into [ThemeData].
  static TextTheme textTheme(TextTheme base) {
    return GoogleFonts.nunitoTextTheme(base).copyWith(
      displayLarge: GoogleFonts.fredoka(
        textStyle: base.displayLarge,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
      displayMedium: GoogleFonts.fredoka(
        textStyle: base.displayMedium,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
      headlineMedium: GoogleFonts.fredoka(
        textStyle: base.headlineMedium,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      titleLarge: GoogleFonts.fredoka(
        textStyle: base.titleLarge,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }
}
