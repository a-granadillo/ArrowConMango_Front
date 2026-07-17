import 'package:equatable/equatable.dart';

/// A single row in a level's own ranking (as opposed to the global
/// leaderboard) — served by `GET /leaderboard?level=`.
///
/// No display name is available on this endpoint (unlike the global
/// leaderboard), so the presentation layer falls back to a truncated
/// [userId].
class LevelRankEntry extends Equatable {
  const LevelRankEntry({
    required this.rank,
    required this.userId,
    required this.moves,
    required this.timeMs,
    required this.value,
  });

  final int rank;
  final String userId;
  final int moves;
  final int timeMs;
  final int value;

  @override
  List<Object?> get props => [rank, userId, moves, timeMs, value];
}
