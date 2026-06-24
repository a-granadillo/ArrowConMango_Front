import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mango_colors.dart';

/// Tema global de ArrowConMango con estética retro y colores de mango
class MangoTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Colores principales
      colorScheme: const ColorScheme.light(
        primary: MangoColors.mangoOrange,
        secondary: MangoColors.leafGreen,
        surface: MangoColors.surface,
        error: MangoColors.error,
      ),
      
      // Fondo general
      scaffoldBackgroundColor: MangoColors.background,
      
      // Tipografía
      textTheme: GoogleFonts.pressStart2pTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        // Títulos grandes (pantallas)
        displayLarge: GoogleFonts.pressStart2p(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: MangoColors.textPrimary,
        ),
        displayMedium: GoogleFonts.pressStart2p(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: MangoColors.textPrimary,
        ),
        
        // Subtítulos
        titleLarge: GoogleFonts.pressStart2p(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: MangoColors.textPrimary,
        ),
        titleMedium: GoogleFonts.pressStart2p(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: MangoColors.textPrimary,
        ),
        
        // Texto normal (usar Roboto para legibilidad)
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16,
          color: MangoColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14,
          color: MangoColors.textSecondary,
        ),
        bodySmall: GoogleFonts.roboto(
          fontSize: 12,
          color: MangoColors.textSecondary,
        ),
      ),
      
      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MangoColors.mangoOrange,
          foregroundColor: MangoColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.pressStart2p(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Tarjetas
      cardTheme: CardThemeData(
        color: MangoColors.cardBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: MangoColors.mangoOrange,
        foregroundColor: MangoColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.pressStart2p(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: MangoColors.textOnPrimary,
        ),
      ),
    );
  }
}
