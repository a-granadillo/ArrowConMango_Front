import 'direction.dart';

/// Spatial directions for movement in 3D space.
///
/// Represents the six orthogonal directions in a cube: the four planar
/// cardinal directions plus depth (fwd/back along the Z axis).
/// This enum is defined in the domain layer to avoid circular dependencies
/// between domain and data layers (mirrors [CardinalDirection]).
enum SpatialDirection implements Direction {
  up,
  down,
  left,
  right,
  fwd,
  back;

  @override
  String get label => name;
}
