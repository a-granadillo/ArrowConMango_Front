import 'package:equatable/equatable.dart';

/// The player's best recorded run for a single level: moves used and time
/// elapsed, in seconds (mirrors [Score.timeElapsed]'s unit — conversion to
/// the backend's milliseconds happens at the datasource boundary, not here).
class LevelBest extends Equatable {
  /// Number of moves used in the best run.
  final int moves;

  /// Time elapsed in the best run, in seconds.
  final int timeElapsedSeconds;

  const LevelBest({
    required this.moves,
    required this.timeElapsedSeconds,
  });

  @override
  List<Object?> get props => [moves, timeElapsedSeconds];

  @override
  String toString() =>
      'LevelBest(moves: $moves, timeElapsedSeconds: $timeElapsedSeconds)';
}
