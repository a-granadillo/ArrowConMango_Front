import 'package:equatable/equatable.dart';

/// Opaque, topology-agnostic identifier for a discrete position in space.
///
/// The domain layer NEVER performs arithmetic on NodeId.
/// All spatial computation is delegated to [Topology].
///
/// Concrete implementations:
///   - Grid2DNodeId(int row, int col)        [Layer 4]
///   - HexNodeId(int q, int r, int s)        [Layer 4]
///   - Cube3DNodeId(int x, int y, int z)     [Layer 4]
abstract class NodeId extends Equatable {
  /// Abstract const constructor to allow const concrete subclasses.
  const NodeId();

  /// A stable, unique string key for use in Sets and Maps.
  /// Must be collision-free within a single topology instance.
  String get key;

  @override
  List<Object?> get props => [key];
}
