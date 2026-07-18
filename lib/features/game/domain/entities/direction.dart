/// Marker interface for a direction of movement within a topology.
///
/// Concrete implementations define the valid direction set:
///   - CardinalDirection { up, right, down, left }       [Layer 4]
///   - HexDirection { n, ne, se, s, sw, nw }             [Layer 4]
///   - SpatialDirection { up, down, left, right, fwd, back } [Layer 4]
abstract class Direction {
  /// Human-readable label for debugging.
  String get label;
}
