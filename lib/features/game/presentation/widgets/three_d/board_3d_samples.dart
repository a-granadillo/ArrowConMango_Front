import '../../../data/topologies/grid_2d_topology.dart';
import '../../../domain/entities/cardinal_direction.dart';
import 'board_3d_view.dart';

/// Sample 3D board used to exercise the issue #44 widget kit end-to-end.
///
/// Hand-picked so every layer has at least one neighboring layer with both a
/// planar and an axial arrow, making the ghosting and ⊙/⊗ glyphs visible no
/// matter which layer the demo opens on. This is sample data, not level
/// data — real 3D levels are tracked separately in issue #43 (3D domain
/// topology), which this file intentionally does not depend on.
abstract final class Board3DSamples {
  static const Board3DModel demo = Board3DModel(
    rows: 5,
    cols: 5,
    layers: 3,
    arrows: [
      // Layer 0 (bottom).
      PlanarArrow3D(
        id: 'l0_h',
        layer: 0,
        direction: CardinalDirection.right,
        occupiedNodes: [
          Grid2DNodeId(row: 1, col: 0),
          Grid2DNodeId(row: 1, col: 1),
        ],
      ),
      PlanarArrow3D(
        id: 'l0_v',
        layer: 0,
        direction: CardinalDirection.down,
        occupiedNodes: [
          Grid2DNodeId(row: 0, col: 3),
          Grid2DNodeId(row: 1, col: 3),
        ],
      ),
      AxialArrow3D(
        id: 'l0_ax',
        layer: 0,
        cell: Grid2DNodeId(row: 3, col: 1),
        facing: ZFacing.forward,
      ),

      // Layer 1 (middle) — the only layer with a neighbor on both sides.
      PlanarArrow3D(
        id: 'l1_h',
        layer: 1,
        direction: CardinalDirection.left,
        occupiedNodes: [
          Grid2DNodeId(row: 2, col: 3),
          Grid2DNodeId(row: 2, col: 2),
        ],
      ),
      PlanarArrow3D(
        id: 'l1_v',
        layer: 1,
        direction: CardinalDirection.up,
        occupiedNodes: [
          Grid2DNodeId(row: 3, col: 1),
          Grid2DNodeId(row: 2, col: 1),
        ],
      ),
      AxialArrow3D(
        id: 'l1_ax1',
        layer: 1,
        cell: Grid2DNodeId(row: 0, col: 4),
        facing: ZFacing.backward,
      ),
      AxialArrow3D(
        id: 'l1_ax2',
        layer: 1,
        cell: Grid2DNodeId(row: 4, col: 0),
        facing: ZFacing.forward,
      ),

      // Layer 2 (top).
      PlanarArrow3D(
        id: 'l2_h',
        layer: 2,
        direction: CardinalDirection.right,
        occupiedNodes: [
          Grid2DNodeId(row: 3, col: 1),
          Grid2DNodeId(row: 3, col: 2),
          Grid2DNodeId(row: 3, col: 3),
        ],
      ),
      PlanarArrow3D(
        id: 'l2_v',
        layer: 2,
        direction: CardinalDirection.down,
        occupiedNodes: [
          Grid2DNodeId(row: 2, col: 4),
          Grid2DNodeId(row: 3, col: 4),
          Grid2DNodeId(row: 4, col: 4),
        ],
      ),
      AxialArrow3D(
        id: 'l2_ax',
        layer: 2,
        cell: Grid2DNodeId(row: 1, col: 1),
        facing: ZFacing.backward,
      ),
    ],
  );
}
