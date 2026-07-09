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
  }) : assert(length >= 0, 'Segment length must be non-negative');

  factory TrajectorySegment.fromJson(Map<String, dynamic> json) {
    final rawLength = json['length'];
    if (rawLength is! int || rawLength < 0) {
      throw ArgumentError(
        'Invalid trajectory segment length: $rawLength (must be a non-negative int)',
      );
    }

    final rawDirection = json['direction'];
    if (rawDirection is! String) {
      throw ArgumentError(
        'Invalid trajectory segment direction: $rawDirection (must be a string)',
      );
    }

    return TrajectorySegment(
      direction: CardinalDirection.values.firstWhere(
        (d) => d.name == rawDirection,
        orElse: () => throw ArgumentError('Invalid direction: $rawDirection'),
      ),
      length: rawLength,
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
