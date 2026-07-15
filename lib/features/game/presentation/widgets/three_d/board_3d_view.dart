import 'package:equatable/equatable.dart';

import '../../../data/topologies/grid_2d_topology.dart';
import '../../../domain/entities/arrow_entity.dart';
import '../../../domain/entities/cardinal_direction.dart';

/// Presentation-only view-model for issue #44 (Z-Layer rendering with
/// ghosting for 3D levels).
///
/// The domain/data layers are 2D-only today — [Grid2DNodeId] is the sole
/// [NodeId], and a real 3D topology (directed graph, `SpatialDirection`) is
/// tracked separately as issue #43, itself blocked on the `BoardGeometry` /
/// Hive migration in issue #42. Neither exists yet, so this view-model keeps
/// the Z-layer UI kit fully decoupled from the domain: it is fed by sample
/// data today and can be re-pointed at real 3D level data once #42/#43 land,
/// without the widgets below needing to change.

/// Which way an [AxialArrow3D] points along the Z axis.
enum ZFacing {
  /// Toward the player, out of the screen — drawn as ⊙.
  forward,

  /// Away from the player, into the board — drawn as ⊗.
  backward,
}

/// A single arrow living on one Z-layer of a 3D board.
sealed class Arrow3DView extends Equatable {
  const Arrow3DView({required this.id, required this.layer});

  /// Unique identifier for this arrow within the board.
  final String id;

  /// The Z-layer (0-based) this arrow lives on.
  final int layer;
}

/// An arrow that moves within its own layer's XY plane, exactly like a 2D
/// [ArrowEntity]. Reuses [CardinalDirection] and the existing arrow painters
/// unchanged — no new geometry needed for the planar case.
class PlanarArrow3D extends Arrow3DView {
  const PlanarArrow3D({
    required super.id,
    required super.layer,
    required this.occupiedNodes,
    required this.direction,
  });

  final List<Grid2DNodeId> occupiedNodes;
  final CardinalDirection direction;

  /// Adapts this view into a plain [ArrowEntity] so it can be drawn by the
  /// existing [ArrowsLayerPainter]/board-tap logic unchanged.
  ArrowEntity toArrowEntity() => ArrowEntity(
        id: id,
        direction: direction,
        occupiedNodes: occupiedNodes,
      );

  @override
  List<Object?> get props => [id, layer, occupiedNodes, direction];
}

/// An arrow that moves along the Z axis out of a single cell — rendered as a
/// ⊙/⊗ glyph by `ZAxisArrowPainter` rather than a stroked polyline.
class AxialArrow3D extends Arrow3DView {
  const AxialArrow3D({
    required super.id,
    required super.layer,
    required this.cell,
    required this.facing,
  });

  final Grid2DNodeId cell;
  final ZFacing facing;

  @override
  List<Object?> get props => [id, layer, cell, facing];
}

/// A 3D board: a stack of [layers] XY planes, each [rows] × [cols], holding a
/// mix of planar and axial arrows.
class Board3DModel extends Equatable {
  const Board3DModel({
    required this.rows,
    required this.cols,
    required this.layers,
    required this.arrows,
  });

  final int rows;
  final int cols;

  /// Number of Z-layers in the board.
  final int layers;

  final List<Arrow3DView> arrows;

  /// The planar arrows living on layer [z].
  List<PlanarArrow3D> planarOn(int z) =>
      arrows.whereType<PlanarArrow3D>().where((a) => a.layer == z).toList();

  /// The axial (Z-facing) arrows living on layer [z].
  List<AxialArrow3D> axialOn(int z) =>
      arrows.whereType<AxialArrow3D>().where((a) => a.layer == z).toList();

  /// The arrow occupying (row, col) on layer [z], if any.
  Arrow3DView? arrowAtCell(int z, int row, int col) {
    final key = Grid2DNodeId(row: row, col: col).key;
    for (final arrow in planarOn(z)) {
      if (arrow.occupiedNodes.any((n) => n.key == key)) return arrow;
    }
    for (final arrow in axialOn(z)) {
      if (arrow.cell.key == key) return arrow;
    }
    return null;
  }

  @override
  List<Object?> get props => [rows, cols, layers, arrows];
}
