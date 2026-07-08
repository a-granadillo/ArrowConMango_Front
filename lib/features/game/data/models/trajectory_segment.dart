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
    return TrajectorySegment(
      direction: CardinalDirection.values.firstWhere(
        (d) => d.name == json['direction'],
        orElse: () => throw ArgumentError('Invalid direction: ${json['direction']}'),
      ),
      length: json['length'] as int,
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
