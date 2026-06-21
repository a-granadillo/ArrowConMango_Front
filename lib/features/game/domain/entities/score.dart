import 'package:equatable/equatable.dart';

/// Immutable value object representing the player's score for a level.
///
/// Stored as raw metrics ([moves], [timeElapsed]) plus the computed
/// [totalPoints].  The [calculateFinal] helper applies a [ScoringStrategy]
/// to produce a new [Score].
class Score extends Equatable {
  /// Number of moves the player made.
  final int moves;

  /// Time spent in seconds.
  final int timeElapsed;

  /// Aggregated point value computed by a [ScoringStrategy].
  final int totalPoints;

  const Score({
    this.moves = 0,
    this.timeElapsed = 0,
    this.totalPoints = 0,
  });

  /// Returns the final aggregated point value.
  ///
  /// When a [ScoringStrategy] has been applied the [totalPoints] already
  /// contain the computed result; otherwise `0` is returned.
  int calculateFinal() => totalPoints;

  /// Creates a [Score] with the given fields replaced.
  Score copyWith({
    int? moves,
    int? timeElapsed,
    int? totalPoints,
  }) {
    return Score(
      moves: moves ?? this.moves,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }

  @override
  List<Object?> get props => [moves, timeElapsed, totalPoints];

  @override
  String toString() =>
      'Score(moves: $moves, time: $timeElapsed, points: $totalPoints)';
}
