import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:arrowconmango_front/features/game/presentation/widgets/painting/arrows_layer_painter.dart';
import 'package:arrowconmango_front/features/game/presentation/widgets/painting/z_axis_arrow_painter.dart';
import 'package:arrowconmango_front/features/game/presentation/widgets/three_d/board_3d_layers_widget.dart';
import 'package:arrowconmango_front/features/game/presentation/widgets/three_d/board_3d_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A 2x2, 3-layer board: layer 0 and 2 each have a horizontal planar arrow
/// on row 0; layer 1 has a planar arrow on row 1 and an axial glyph at
/// (0,0), so every layer has a distinct, checkable arrow to tap.
const _model = Board3DModel(
  rows: 2,
  cols: 2,
  layers: 3,
  arrows: [
    PlanarArrow3D(
      id: 'a0',
      layer: 0,
      direction: CardinalDirection.right,
      occupiedNodes: [
        Grid2DNodeId(row: 0, col: 0),
        Grid2DNodeId(row: 0, col: 1),
      ],
    ),
    PlanarArrow3D(
      id: 'a1',
      layer: 1,
      direction: CardinalDirection.right,
      occupiedNodes: [
        Grid2DNodeId(row: 1, col: 0),
        Grid2DNodeId(row: 1, col: 1),
      ],
    ),
    AxialArrow3D(
      id: 'ax1',
      layer: 1,
      cell: Grid2DNodeId(row: 0, col: 0),
      facing: ZFacing.forward,
    ),
    PlanarArrow3D(
      id: 'a2',
      layer: 2,
      direction: CardinalDirection.right,
      occupiedNodes: [
        Grid2DNodeId(row: 0, col: 0),
        Grid2DNodeId(row: 0, col: 1),
      ],
    ),
  ],
);

void main() {
  Future<void> pumpBoard(
    WidgetTester tester, {
    void Function(String)? onTap,
    int initialLayer = 0,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 520,
            child: Board3DLayersWidget(
              model: _model,
              colorOf: (_) => Colors.orange,
              initialLayer: initialLayer,
              onArrowTap: onTap,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> tapCell(WidgetTester tester, int row, int col) async {
    final gd = find.byKey(const Key('board3dGesture'));
    final topLeft = tester.getTopLeft(gd);
    final size = tester.getSize(gd);
    final cell = size.width / _model.cols;
    await tester.tapAt(
      topLeft + Offset((col + 0.5) * cell, (row + 0.5) * cell),
    );
    await tester.pump();
  }

  testWidgets('should_render_one_chip_per_layer', (tester) async {
    await pumpBoard(tester);

    expect(find.text('Capa 1'), findsOneWidget);
    expect(find.text('Capa 2'), findsOneWidget);
    expect(find.text('Capa 3'), findsOneWidget);
  });

  testWidgets(
    'should_render_a_solid_planar_layer_and_one_ghost_when_starting_on_an_edge_layer',
    (tester) async {
      await pumpBoard(tester); // initialLayer 0 → only neighbor is layer 1.

      final painters = tester
          .widgetList<CustomPaint>(
            find.byWidgetPredicate(
              (w) => w is CustomPaint && w.painter is ArrowsLayerPainter,
            ),
          )
          .map((w) => w.painter! as ArrowsLayerPainter)
          .toList();

      expect(painters, hasLength(2));
      expect(painters.where((p) => p.opacity == 1.0), hasLength(1));
      expect(
        painters.where((p) => p.opacity == Board3DLayersWidget.ghostOpacity),
        hasLength(1),
      );
    },
  );

  testWidgets('should_render_two_ghost_layers_when_on_the_middle_layer', (
    tester,
  ) async {
    await pumpBoard(tester, initialLayer: 1); // has neighbors on both sides.

    final painters = tester
        .widgetList<CustomPaint>(
          find.byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is ArrowsLayerPainter,
          ),
        )
        .map((w) => w.painter! as ArrowsLayerPainter)
        .toList();

    expect(painters, hasLength(3)); // 1 solid + 2 ghosts (layer 0 and layer 2).
    expect(
      painters.where((p) => p.opacity == Board3DLayersWidget.ghostOpacity),
      hasLength(2),
    );
  });

  testWidgets('should_render_a_z_axis_painter_for_the_axial_arrow', (
    tester,
  ) async {
    await pumpBoard(tester, initialLayer: 1);

    final zPainters = tester
        .widgetList<CustomPaint>(
          find.byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is ZAxisArrowPainter,
          ),
        )
        .map((w) => w.painter! as ZAxisArrowPainter)
        .toList();

    final solidWithAxial = zPainters.where(
      (p) => p.opacity == 1.0 && p.arrows.isNotEmpty,
    );
    expect(solidWithAxial, hasLength(1));
    expect(solidWithAxial.first.arrows.single.id, 'ax1');
  });

  testWidgets('tapping_a_chip_switches_the_active_layer', (tester) async {
    String? tapped;
    await pumpBoard(tester, onTap: (id) => tapped = id); // starts on layer 0.

    await tester.tap(find.text('Capa 3'));
    await tester.pump();

    await tapCell(tester, 0, 0);

    expect(tapped, 'a2');
  });

  testWidgets('tapping_a_cell_reports_the_planar_arrow_occupying_it', (
    tester,
  ) async {
    String? tapped;
    await pumpBoard(tester, onTap: (id) => tapped = id); // layer 0.

    await tapCell(tester, 0, 0);

    expect(tapped, 'a0');
  });

  testWidgets('tapping_a_cell_reports_the_axial_arrow_occupying_it', (
    tester,
  ) async {
    String? tapped;
    await pumpBoard(tester, onTap: (id) => tapped = id, initialLayer: 1);

    await tapCell(tester, 0, 0); // (0,0) on layer 1 holds the axial arrow.

    expect(tapped, 'ax1');
  });

  testWidgets('tapping_an_empty_cell_does_not_invoke_the_callback', (
    tester,
  ) async {
    String? tapped;
    await pumpBoard(tester, onTap: (id) => tapped = id, initialLayer: 1);

    // Layer 1 occupies (1,0)/(1,1) with a1 and (0,0) with ax1 — (0,1) is empty.
    await tapCell(tester, 0, 1);

    expect(tapped, isNull);
  });
}
