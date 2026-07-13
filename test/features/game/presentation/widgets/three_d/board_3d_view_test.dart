import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:arrowconmango_front/features/game/presentation/widgets/three_d/board_3d_view.dart';
import 'package:flutter_test/flutter_test.dart';

const _planar = PlanarArrow3D(
  id: 'planar',
  layer: 0,
  direction: CardinalDirection.right,
  occupiedNodes: [Grid2DNodeId(row: 0, col: 0), Grid2DNodeId(row: 0, col: 1)],
);

const _axial = AxialArrow3D(
  id: 'axial',
  layer: 0,
  cell: Grid2DNodeId(row: 2, col: 2),
  facing: ZFacing.forward,
);

const _otherLayerPlanar = PlanarArrow3D(
  id: 'planar_l1',
  layer: 1,
  direction: CardinalDirection.down,
  occupiedNodes: [Grid2DNodeId(row: 1, col: 1), Grid2DNodeId(row: 2, col: 1)],
);

void main() {
  group('PlanarArrow3D.toArrowEntity', () {
    test('carries_over_id_direction_and_occupied_nodes', () {
      final entity = _planar.toArrowEntity();
      expect(entity.id, 'planar');
      expect(entity.direction, CardinalDirection.right);
      expect(entity.occupiedNodes, _planar.occupiedNodes);
    });
  });

  group('Board3DModel', () {
    const model = Board3DModel(
      rows: 3,
      cols: 3,
      layers: 2,
      arrows: [_planar, _axial, _otherLayerPlanar],
    );

    test('planarOn_filters_by_layer', () {
      expect(model.planarOn(0), [_planar]);
      expect(model.planarOn(1), [_otherLayerPlanar]);
    });

    test('axialOn_filters_by_layer', () {
      expect(model.axialOn(0), [_axial]);
      expect(model.axialOn(1), isEmpty);
    });

    test('arrowAtCell_finds_a_planar_arrow_by_any_occupied_cell', () {
      expect(model.arrowAtCell(0, 0, 1), _planar);
    });

    test('arrowAtCell_finds_an_axial_arrow_by_its_single_cell', () {
      expect(model.arrowAtCell(0, 2, 2), _axial);
    });

    test('arrowAtCell_returns_null_for_an_empty_cell', () {
      expect(model.arrowAtCell(0, 2, 0), isNull);
    });

    test('arrowAtCell_does_not_leak_across_layers', () {
      expect(model.arrowAtCell(0, 1, 1), isNull);
      expect(model.arrowAtCell(1, 1, 1), _otherLayerPlanar);
    });
  });
}
