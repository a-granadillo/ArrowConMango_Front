import 'package:flutter/material.dart';

/// Mango-inspired color palette for ArrowConMango
class MangoColors {
  MangoColors._();

  // Primary colors
  static const Color mangoYellow = Color(0xFFFFB800);
  static const Color mangoOrange = Color(0xFFFF8C00);
  static const Color mangoRed = Color(0xFFFF6B00);

  // Secondary colors
  static const Color leafGreen = Color(0xFF4CAF50);
  static const Color darkLeafGreen = Color(0xFF2E7D32);

  // Neutral colors
  static const Color background = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF2D2D2D);
  static const Color cardBackground = Color(0xFF3D3D3D);

  // Error color
  static const Color error = Color(0xFFB00020);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);

  // Arrow colors for the game
  static const List<Color> arrowColors = [
    mangoOrange,
    leafGreen,
    mangoYellow,
    mangoRed,
    darkLeafGreen,
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
  ];
}
