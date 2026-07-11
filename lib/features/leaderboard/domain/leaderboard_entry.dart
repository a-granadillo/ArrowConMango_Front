import 'package:equatable/equatable.dart';

/// A single row in the global leaderboard.
class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    required this.rank,
    required this.uuid,
    required this.displayName,
    required this.mangos,
    this.isCurrentPlayer = false,
  });

  /// 1-based position in the ranking.
  final int rank;

  /// Anonymous player id (UUID).
  final String uuid;

  /// Public display name.
  final String displayName;

  /// Score (collected mangos).
  final int mangos;

  /// Whether this row is the local guest player (highlighted in the UI).
  final bool isCurrentPlayer;

  /// First letter used for the avatar badge.
  String get initial =>
      displayName.isEmpty ? '?' : displayName.substring(0, 1).toUpperCase();

  @override
  List<Object?> get props => [rank, uuid, displayName, mangos, isCurrentPlayer];
}
