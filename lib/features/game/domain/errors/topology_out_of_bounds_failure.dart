import 'failure.dart';

/// A topology computation exceeded the valid bounds of the space.
///
/// Raised when a trajectory, neighbor, or shift query produces
/// coordinates outside the topology's boundaries — typically
/// caused by invalid input or a bug in level definitions.
class TopologyOutOfBoundsFailure extends Failure {
  /// Human-readable description of which coordinate or node was invalid.
  final String coordinate;

  const TopologyOutOfBoundsFailure({required this.coordinate})
      : super('Coordinate "$coordinate" is outside the topology bounds');

  @override
  List<Object?> get props => [message, coordinate];
}
