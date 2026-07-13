import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_colors.dart';
import '../painting/arrows_layer_painter.dart';
import '../painting/board_surface_painter.dart';
import '../painting/z_axis_arrow_painter.dart';
import 'board_3d_view.dart';

/// Renders a [Board3DModel] one Z-layer at a time: the active layer's arrows
/// are drawn solid, and its immediate neighbors (Z±1) are drawn as
/// translucent "ghosts" so players can see what blocks the active layer
/// without losing track of which layer they're editing (issue #44).
///
/// Reuses the existing 2D painters — [ArrowsLayerPainter] (via its `opacity`
/// knob) and [BoardSurfacePainter] — plus the new [ZAxisArrowPainter] for
/// arrows that move along the Z axis.
class Board3DLayersWidget extends StatefulWidget {
  const Board3DLayersWidget({
    super.key,
    required this.model,
    required this.colorOf,
    this.initialLayer = 0,
    this.onArrowTap,
  });

  final Board3DModel model;

  /// Stable color for an arrow id (see `ArrowColorAssigner`).
  final Color Function(String id) colorOf;

  final int initialLayer;
  final void Function(String arrowId)? onArrowTap;

  /// Opacity applied to ghosted arrows from the adjacent Z-layers.
  static const double ghostOpacity = 0.3;

  @override
  State<Board3DLayersWidget> createState() => _Board3DLayersWidgetState();
}

class _Board3DLayersWidgetState extends State<Board3DLayersWidget> {
  late int _layer;

  @override
  void initState() {
    super.initState();
    _layer = widget.initialLayer.clamp(0, widget.model.layers - 1).toInt();
  }

  void _selectLayer(int z) => setState(() => _layer = z);

  void _handleTap(Offset local, double cell) {
    final model = widget.model;
    final col = (local.dx / cell).floor().clamp(0, model.cols - 1);
    final row = (local.dy / cell).floor().clamp(0, model.rows - 1);
    final arrow = model.arrowAtCell(_layer, row, col);
    if (arrow != null) widget.onArrowTap?.call(arrow.id);
  }

  List<Widget> _ghostLayers(int z, double cell) => [
        Positioned.fill(
          child: CustomPaint(
            painter: ArrowsLayerPainter(
              arrows: widget.model
                  .planarOn(z)
                  .map((a) => a.toArrowEntity())
                  .toList(),
              colorOf: widget.colorOf,
              cell: cell,
              opacity: Board3DLayersWidget.ghostOpacity,
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: ZAxisArrowPainter(
              arrows: widget.model.axialOn(z),
              colorOf: widget.colorOf,
              cell: cell,
              opacity: Board3DLayersWidget.ghostOpacity,
            ),
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LayerSelector(
          layers: model.layers,
          selected: _layer,
          onSelect: _selectLayer,
        ),
        const SizedBox(height: 8),
        const _GlyphLegend(),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppColors.textDark,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x526D4C2A),
                blurRadius: 28,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: model.cols / model.rows,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cell = constraints.maxWidth / model.cols;
                return GestureDetector(
                  key: const Key('board3dGesture'),
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) =>
                      _handleTap(details.localPosition, cell),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(painter: BoardSurfacePainter(cell)),
                        ),
                        if (_layer - 1 >= 0) ..._ghostLayers(_layer - 1, cell),
                        if (_layer + 1 < model.layers)
                          ..._ghostLayers(_layer + 1, cell),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: ArrowsLayerPainter(
                              arrows: model
                                  .planarOn(_layer)
                                  .map((a) => a.toArrowEntity())
                                  .toList(),
                              colorOf: widget.colorOf,
                              cell: cell,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: ZAxisArrowPainter(
                              arrows: model.axialOn(_layer),
                              colorOf: widget.colorOf,
                              cell: cell,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Row of one chip per Z-layer ("Capa 1", "Capa 2", …); the active layer is
/// highlighted, matching the stat-chip styling used elsewhere in the game UI.
class _LayerSelector extends StatelessWidget {
  const _LayerSelector({
    required this.layers,
    required this.selected,
    required this.onSelect,
  });

  final int layers;
  final int selected;
  final void Function(int z) onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var z = 0; z < layers; z++) ...[
          if (z > 0) const SizedBox(width: 8),
          Expanded(
            child: _LayerChip(
              label: 'Capa ${z + 1}',
              selected: z == selected,
              onTap: () => onSelect(z),
            ),
          ),
        ],
      ],
    );
  }
}

class _LayerChip extends StatelessWidget {
  const _LayerChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.beige,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

/// Short legend explaining the ⊙ (toward the player) / ⊗ (into the board)
/// glyphs drawn by [ZAxisArrowPainter].
class _GlyphLegend extends StatelessWidget {
  const _GlyphLegend();

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.nunito(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AppColors.textMuted,
    );
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      children: [
        Text('⊙ hacia ti', style: style),
        Text('⊗ hacia el tablero', style: style),
      ],
    );
  }
}
