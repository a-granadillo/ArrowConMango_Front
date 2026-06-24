import 'direction.dart';

/// Concrete 4-direction cardinal set for 2D grids.
///
/// Defined in the domain layer so domain services can reference
/// concrete directions without depending on infrastructure.
enum CardinalDirection implements Direction {
  up,
  right,
  down,
  left;

  @override
  String get label => name;
}
