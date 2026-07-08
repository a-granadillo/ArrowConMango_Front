import 'package:equatable/equatable.dart';

import '../../domain/entities/cardinal_direction.dart';

/// Represents a single straight segment of an arrow's trajectory.
///
/// Each segment has a [direction] and a [length] (number of cells).
/// Segments can be chained together to form complex paths with 90° turns.
class TrajectorySegment extends Equatable {
  /// The direction this segment travels.
  final CardinalDirection direction;

  /// Number of cells this segment spans (must be >= 1).
  final int length;

  const TrajectorySegment({
    required this.direction,
    required this.length,
  }) : assert(length >= 1, 'Segment length must be at least 1');

  factory TrajectorySegment.fromJson(Map<String, dynamic> json) {
    final directionRaw = json['direction'];
    if (directionRaw is! String) {
      throw ArgumentError.value(directionRaw, 'direction', 'Direction must be a string');
    }

    final lengthRaw = json['length'];
    if (lengthRaw is! int || lengthRaw < 1) {
      throw ArgumentError.value(lengthRaw, 'length', 'Segment length must be an int >= 1');
    }

    return TrajectorySegment(
      direction: CardinalDirection.values.firstWhere(
        (d) => d.name == directionRaw,
        orElse: () => throw ArgumentError('Invalid direction: $directionRaw'),
      ),
      length: lengthRaw,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'direction': direction.name,
      'length': length,
    };
  }

  @override
  List<Object?> get props => [direction, length];
}
