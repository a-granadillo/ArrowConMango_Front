import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:arrowconmango_front/features/game/presentation/widgets/board_grid_widget.dart';
import 'package:arrowconmango_front/features/game/presentation/widgets/painting/arrows_layer_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/game_test_setup.dart';

void main() {
  Future<void> pumpBoard(
    WidgetTester tester, {
    required List<ArrowEntity> arrows,
    required void Function(String) onTap,
    int rows = 4,
    int cols = 4,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 320,
              child: BoardGridWidget(
                rows: rows,
                cols: cols,
                arrows: arrows,
                colorOf: (_) => Colors.orange,
                onArrowTap: onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Taps the center of board cell (row, col).
  Future<void> tapCell(WidgetTester tester, int row, int col, int cols) async {
    final gd = find.byType(GestureDetector);
    final topLeft = tester.getTopLeft(gd);
    final size = tester.getSize(gd);
    final cell = size.width / cols;
    await tester.tapAt(topLeft + Offset((col + 0.5) * cell, (row + 0.5) * cell));
    await tester.pump();
  }

  testWidgets('should_render_the_arrows_layer_painter', (tester) async {
    // Act
    await pumpBoard(
      tester,
      arrows: [horizontalArrow('a1', row: 0), horizontalArrow('a2', row: 2)],
      onTap: (_) {},
    );

    // Assert
    expect(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is ArrowsLayerPainter,
      ),
      findsOneWidget,
    );
  });

  testWidgets('should_report_the_arrow_occupying_the_tapped_cell',
      (tester) async {
    // Arrange
    String? tapped;
    await pumpBoard(
      tester,
      arrows: [horizontalArrow('a1', row: 0), horizontalArrow('a2', row: 2)],
      onTap: (id) => tapped = id,
    );

    // Act: a1 occupies row 0.
    await tapCell(tester, 0, 0, 4);

    // Assert
    expect(tapped, 'a1');
  });

  testWidgets(
      'should_report_the_straight_arrow_when_an_L_arrows_bbox_overlaps_it',
      (tester) async {
    // Arrange: a bent arrow whose bounding box covers cell (0,0), but a
    // straight arrow actually occupies (0,0). Cell-based hit testing must
    // report the straight one, not the L whose box merely overlaps.
    final lArrow = ArrowEntity(
      id: 'bent',
      direction: CardinalDirection.right,
      occupiedNodes: const [
        Grid2DNodeId(row: 2, col: 0), // tail
        Grid2DNodeId(row: 1, col: 0),
        Grid2DNodeId(row: 0, col: 1), // NOT (0,0) — bbox covers (0,0) though
      ],
    );
    final straight = horizontalArrow('straight', row: 0); // occupies (0,0),(0,1)

    String? tapped;
    await pumpBoard(
      tester,
      arrows: [lArrow, straight],
      onTap: (id) => tapped = id,
    );

    // Act: tap cell (0,0).
    await tapCell(tester, 0, 0, 4);

    // Assert
    expect(tapped, 'straight');
  });
}
