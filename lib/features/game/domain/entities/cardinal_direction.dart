import 'direction.dart';

/// Cardinal directions for movement in 2D space.
///
/// Represents the four cardinal directions: up, down, left, right.
/// This enum is defined in the domain layer to avoid circular dependencies
/// between domain and data layers.
enum CardinalDirection implements Direction {
  up,
  right,
  down,
  left;

  @override
  String get label => name;
}
