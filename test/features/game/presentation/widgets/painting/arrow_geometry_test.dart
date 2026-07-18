import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:arrowconmango_front/features/game/presentation/widgets/painting/arrow_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/game_test_setup.dart';

const _cell = 40.0;

double _bodyLength(ArrowEntity a) =>
    buildBodyPath(a, _cell).computeMetrics().first.length;

void main() {
  group('buildBodyPath', () {
    test('straight_3_cell_body_has_length_2_cells', () {
      // (0,0)-(0,1)-(0,2): two segments of one cell each.
      final a = horizontalArrow('a', row: 0, startCol: 0, length: 3);
      expect(_bodyLength(a), closeTo(2 * _cell, 0.001));
    });

    test('single_cell_arrow_has_non_empty_metrics', () {
      const a = ArrowEntity(
        id: 'a',
        direction: CardinalDirection.up,
        occupiedNodes: [Grid2DNodeId(row: 3, col: 3)],
      );
      final metrics = buildBodyPath(a, _cell).computeMetrics().toList();
      expect(metrics, isNotEmpty);
      expect(metrics.first.length, greaterThan(0));
    });

    test('L_shaped_body_is_a_single_contour', () {
      // down then right: (0,0)-(1,0)-(1,1).
      const a = ArrowEntity(
        id: 'a',
        direction: CardinalDirection.right,
        occupiedNodes: [
          Grid2DNodeId(row: 0, col: 0),
          Grid2DNodeId(row: 1, col: 0),
          Grid2DNodeId(row: 1, col: 1),
        ],
      );
      final metrics = buildBodyPath(a, _cell).computeMetrics().toList();
      expect(metrics, hasLength(1));
      expect(metrics.first.length, closeTo(2 * _cell, 0.001));
    });

    test(
      'a_straight_horizontal_arrows_bounding_box_has_zero_height '
      '(regression: ArrowImpactPainter used to gate painting on '
      "path.getBounds().isEmpty, which Flutter's Rect also reports true "
      'for a zero-height/width rect — silently skipping every straight '
      'arrow, i.e. most arrows in the game)',
      () {
        final a = horizontalArrow('a', row: 0, startCol: 0, length: 3);
        final path = buildBodyPath(a, _cell);

        // The bug: a straight horizontal line's bounding rect has zero
        // height, and Rect.isEmpty treats that as "empty" too.
        expect(path.getBounds().isEmpty, isTrue);

        // The fix: the path itself is real and must be painted —
        // computeMetrics().isEmpty is the correct "anything to draw?" check.
        expect(path.computeMetrics().isEmpty, isFalse);
      },
    );
  });

  group('exitCells', () {
    test('counts_in_board_steps_plus_one_margin', () {
      // Head at (0,2) on a 4x4 board pointing right → cols 3 in-board + 1.
      final a = horizontalArrow('a', row: 0, startCol: 1, length: 2); // head (0,2)
      expect(exitCells(a, 4, 4), 1 /* col 3 */ + 1 /* margin */);
    });

    test('head_on_edge_yields_just_the_margin', () {
      // Head at (0,3) pointing right on a 4-col board → 0 in-board + 1.
      final a = horizontalArrow('a', row: 0, startCol: 2, length: 2); // head (0,3)
      expect(exitCells(a, 4, 4), 1);
    });
  });

  group('buildExitPath', () {
    test('is_a_single_contour_of_body_plus_exit_extension', () {
      final a = horizontalArrow('a', row: 0, startCol: 0, length: 2); // head (0,1)
      final metrics =
          buildExitPath(a, _cell, 4, 4).computeMetrics().toList();
      expect(metrics, hasLength(1));
      // body (1 cell) + exit (cols 2,3 = 2 in-board + 1 margin = 3 cells).
      expect(metrics.first.length, closeTo((1 + 3) * _cell, 0.001));
    });
  });
}
