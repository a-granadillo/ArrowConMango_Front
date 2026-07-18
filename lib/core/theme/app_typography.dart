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
