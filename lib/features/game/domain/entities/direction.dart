/// Cardinal directions used by arrow cells and neighbour lookups.
///
/// The order [up, right, down, left] corresponds to a clockwise rotation
/// sequence: calling `Direction.values[(d.index + 1) % 4]` rotates 90° CW.
enum Direction {
  up,
  right,
  down,
  left,
}
