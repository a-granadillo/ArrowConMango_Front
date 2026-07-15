import 'dart:ui';

/// Pure geometry helpers for the Z-axis glyphs drawn by [ZAxisArrowPainter]
/// for arrows that point into/out of the screen on a 3D board: ⊙ (forward,
/// toward the player) and ⊗ (backward, into the board). No Flutter
/// widget/state here so everything is trivially unit-testable, mirroring
/// `arrow_geometry.dart`'s split for planar arrows.

/// Radius of the glyph's outer ring, relative to a cell.
double glyphRadiusFor(double cell) => cell * 0.30;

/// Radius of the small filled dot at the center of the ⊙ (forward) glyph.
double glyphDotRadiusFor(double cell) => cell * 0.11;

/// The outer ring shared by both glyphs.
Path buildGlyphRing(Offset center, double cell) => Path()
  ..addOval(Rect.fromCircle(center: center, radius: glyphRadiusFor(cell)));

/// The filled center dot for the ⊙ (forward, "toward the player") glyph.
Path buildForwardDot(Offset center, double cell) => Path()
  ..addOval(Rect.fromCircle(center: center, radius: glyphDotRadiusFor(cell)));

/// The diagonal cross for the ⊗ (backward, "into the board") glyph, its arms
/// inscribed within the outer ring.
Path buildBackwardCross(Offset center, double cell) {
  final arm = glyphRadiusFor(cell) * 0.7;
  return Path()
    ..moveTo(center.dx - arm, center.dy - arm)
    ..lineTo(center.dx + arm, center.dy + arm)
    ..moveTo(center.dx + arm, center.dy - arm)
    ..lineTo(center.dx - arm, center.dy + arm);
}
