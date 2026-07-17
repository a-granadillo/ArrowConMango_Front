import 'package:equatable/equatable.dart';

/// A single row in a level's own ranking (as opposed to the global
/// leaderboard) — served by `GET /leaderboard/:nivel`.
class LevelRankEntry extends Equatable {
  const LevelRankEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.moves,
    required this.timeMs,
    required this.value,
    this.isMe = false,
  });

  final int rank;
  final String userId;
  final String displayName;
  final int moves;
  final int timeMs;
  final int value;
  final bool isMe;

  @override
  List<Object?> get props =>
      [rank, userId, displayName, moves, timeMs, value, isMe];
}
