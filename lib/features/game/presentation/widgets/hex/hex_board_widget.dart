import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/arrow_entity.dart';
import '../board_grid_widget.dart' show ExitingArrowData, ImpactingArrowData;
import 'hex_arrow_exit_animation.dart';
import 'hex_arrow_impact_animation.dart';
import 'hex_board_painter.dart';
import 'hex_geometry.dart';

/// Renders the hexagonal puzzle board: a dark-wood frame (matching
/// [BoardGridWidget]'s look) around a hex grid, with arrows drawn as thin
/// snake-like strokes through hex-cell centers.
///
/// Tapping is resolved by hex cell — the tapped pixel maps to an axial
/// `(q, r)` via [pixelToAxial], and the arrow occupying that cell is
/// reported via [onArrowTap]. Exit/impact animation overlays reuse
/// [BoardGridWidget]'s [ExitingArrowData]/[ImpactingArrowData] data classes
/// (they're board-shape-agnostic — just an id/arrow/callback bundle).
class HexBoardWidget extends StatelessWidget {
  const HexBoardWidget({
    super.key,
    required this.radius,
    required this.arrows,
    required this.onArrowTap,
    required this.colorOf,
    this.exitingArrows = const [],
    this.impactingArrows = const [],
    this.onArrowLongPress,
  });

  final int radius;
  final List<ArrowEntity> arrows;
  final void Function(String arrowId) onArrowTap;

  /// Stable color for an arrow id (see [ArrowColorAssigner]).
  final Color Function(String id) colorOf;

  final List<ExitingArrowData> exitingArrows;

  /// Arrows currently flashing an impact animation (see [ImpactingArrowData]).
  final List<ImpactingArrowData> impactingArrows;

  /// Callback for long-press on a switchable arrow.
  final void Function(String arrowId)? onArrowLongPress;

  static const double _sqrt3 = 1.7320508075688772;

  double _hexSizeFor(double maxWidth, double maxHeight) {
    final widthFactor = _sqrt3 * (2 * radius + 1);
    // Pointy-top hex: row-center spacing is 1.5*size and row centers span
    // 2*radius rows, so the row-center range alone is 3*radius*size; add
    // one hex's half-height (= size) on top and bottom for the true extent.
    final heightFactor = 3 * radius + 2;
    return [
      maxWidth / widthFactor,
      maxHeight / heightFactor,
    ].reduce((a, b) => a < b ? a : b);
  }

  void _handleTap(Offset local, double hexSize, Offset origin) {
    final (q, r) = pixelToAxial(local - origin, hexSize);
    final key = '${q}_$r';
    for (final arrow in arrows) {
      if (arrow.occupiedNodes.any((n) => n.key == key)) {
        onArrowTap(arrow.id);
        return;
      }
    }
  }

  void _handleLongPress(Offset local, double hexSize, Offset origin) {
    if (onArrowLongPress == null) return;
    final (q, r) = pixelToAxial(local - origin, hexSize);
    final key = '${q}_$r';
    for (final arrow in arrows) {
      if (arrow.occupiedNodes.any((n) => n.key == key)) {
        if (arrow.isSwitchable) {
          onArrowLongPress!(arrow.id);
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Same dark-wood frame as BoardGridWidget, for visual consistency
    // between game modes.
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.textDark,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x526D4C2A), blurRadius: 28, offset: Offset(0, 8)),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hexSize =
                _hexSizeFor(constraints.maxWidth, constraints.maxHeight);
            final origin =
                Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) =>
                  _handleTap(details.localPosition, hexSize, origin),
              onLongPressStart: (details) =>
                  _handleLongPress(details.localPosition, hexSize, origin),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: HexSurfacePainter(
                          radius: radius,
                          hexSize: hexSize,
                          origin: origin,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: HexArrowsLayerPainter(
                          arrows: arrows,
                          colorOf: colorOf,
                          hexSize: hexSize,
                          origin: origin,
                        ),
                      ),
                    ),
                    for (final exiting in exitingArrows)
                      Positioned.fill(
                        key: ValueKey(exiting.id),
                        child: HexArrowExitAnimation(
                          arrow: exiting.arrow,
                          hexSize: hexSize,
                          radius: radius,
                          origin: origin,
                          color: exiting.color,
                          onComplete: exiting.onComplete,
                        ),
                      ),
                    for (final impacting in impactingArrows)
                      Positioned.fill(
                        key: ValueKey(impacting.id),
                        child: HexArrowImpactAnimation(
                          arrow: impacting.arrow,
                          hexSize: hexSize,
                          origin: origin,
                          onComplete: impacting.onComplete,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
