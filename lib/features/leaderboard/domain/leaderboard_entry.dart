import 'package:equatable/equatable.dart';

/// What [LeaderboardEntry.secondaryValue] counts, so the UI knows how to
/// label it (levels completed doesn't apply to a per-level or survival
/// ranking the same way "moves" or "runs" do).
enum LeaderboardMetric { levels, moves, survivalRuns }

/// A single row in a leaderboard — either a level's own ranking or the
/// survival ranking. [mangos] is the headline number next to the mango icon
/// (mango stars for survival, score points for a level); [secondaryValue]
/// is a smaller supporting count whose meaning [metric] disambiguates.
class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    required this.rank,
    required this.uuid,
    required this.displayName,
    required this.mangos,
    required this.colorValue,
    this.secondaryValue = 0,
    this.metric = LeaderboardMetric.levels,
    this.isCurrentPlayer = false,
  });

  /// 1-based position in the full ranking (not just the visible top slice).
  final int rank;

  /// Anonymous player id (UUID).
  final String uuid;

  /// Public display name.
  final String displayName;

  /// Headline number shown next to the mango icon.
  final int mangos;

  /// Avatar background color as a 0xAARRGGBB value, matching the design's
  /// per-player palette. Kept as a raw int (not `Color`) so the domain layer
  /// stays Flutter-free; the presentation layer maps it to a `Color`.
  final int colorValue;

  /// Secondary count shown as the subtitle under the name — see [metric].
  final int secondaryValue;

  /// Disambiguates what [secondaryValue] counts.
  final LeaderboardMetric metric;

  /// Whether this row is the requesting player (backend-flagged `isMe`).
  final bool isCurrentPlayer;

  /// First letter used for the avatar badge.
  String get initial =>
      displayName.isEmpty ? '?' : displayName.substring(0, 1).toUpperCase();

  @override
  List<Object?> get props => [
        rank,
        uuid,
        displayName,
        mangos,
        colorValue,
        secondaryValue,
        metric,
        isCurrentPlayer,
      ];
}

/// A leaderboard response: the visible top slice, plus the requesting
/// player's own row with their real rank — present even when they fall
/// outside [top], so the UI can pin it at the bottom (see
/// `GET /leaderboard/:nivel` and `GET /leaderboard/supervivencia`).
class LeaderboardPage extends Equatable {
  const LeaderboardPage({required this.top, required this.me});

  final List<LeaderboardEntry> top;
  final LeaderboardEntry? me;

  @override
  List<Object?> get props => [top, me];
}
