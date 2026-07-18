import 'direction.dart';

/// The six pointy-top hexagon directions for movement in hexagonal space.
///
/// Named by compass point (north, north-east, south-east, south, south-west,
/// north-west) — the natural vocabulary for a pointy-top hex grid, where each
/// cell has neighbors above/below and to the four diagonals instead of the
/// four cardinal directions of a square grid.
/// This enum is defined in the domain layer to avoid circular dependencies
/// between domain and data layers (mirrors [CardinalDirection] and
/// [SpatialDirection]).
enum HexDirection implements Direction {
  n,
  ne,
  se,
  s,
  sw,
  nw;

  @override
  String get label => name;
}
