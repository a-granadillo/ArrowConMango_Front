import 'package:equatable/equatable.dart';

import 'direction.dart';

/// Immutable value object representing a coordinate on the board grid.
///
/// `x` is the row index (vertical axis, 0 = top).
/// `y` is the column index (horizontal axis, 0 = left).
///
/// Uses [Equatable] so two positions with the same coordinates are value-equal,
/// enabling correct BLoC state change detection.
class Position extends Equatable {
  /// Row index (0-based from top).
  final int x;

  /// Column index (0-based from left).
  final int y;

  const Position({required this.x, required this.y});

  /// Returns a new [Position] shifted one step in the given [direction].
  ///
  /// Does **not** perform bounds checking; the caller is responsible for
  /// validating the resulting coordinates against the board dimensions.
  Position move(Direction direction) {
    switch (direction) {
      case Direction.up:
        return Position(x: x - 1, y: y);
      case Direction.down:
        return Position(x: x + 1, y: y);
      case Direction.left:
        return Position(x: x, y: y - 1);
      case Direction.right:
        return Position(x: x, y: y + 1);
    }
  }

  /// String key suitable for use as a [Set] entry in visited-position
  /// tracking (e.g., within [Board.isPathClear]).
  String get key => '${x}_$y';

  @override
  List<Object?> get props => [x, y];

  @override
  String toString() => 'Position(x: $x, y: $y)';
}
