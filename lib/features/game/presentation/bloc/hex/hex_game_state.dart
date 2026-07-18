import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/hex_level.dart';
import 'package:arrowconmango_front/features/game/domain/entities/score.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_state.dart'
    show DefeatReason;
import 'package:equatable/equatable.dart';

enum HexStatus { loading, playing, victory, defeat }

/// State for [HexGameCubit] — the hexagonal-board mode.
///
/// A single flat class (rather than sealed subclasses like [GameState]),
/// mirroring [Cube3DGameState]: every field but [level]/[board] is
/// meaningful across all statuses and the UI only reads them once [status]
/// has left [HexStatus.loading].
class HexGameState extends Equatable {
  const HexGameState({
    required this.status,
    this.level,
    this.board,
    this.radius = 0,
    this.levelIndex = 0,
    this.totalLevels = 0,
    this.moveCount = 0,
    this.mistakes = 0,
    this.elapsedSeconds = 0,
    this.score,
    this.defeatReason,
    this.exitableIds = const {},
    this.lastBlockedId,
  });

  static const loading = HexGameState(status: HexStatus.loading);

  final HexStatus status;
  final HexLevel? level;
  final BoardState? board;
  final int radius;

  /// Zero-based index of [level] within the loaded catalogue.
  final int levelIndex;

  /// Total number of levels in the loaded catalogue.
  final int totalLevels;

  /// Total taps attempted — successful exits AND blocked (wrong) attempts
  /// both count, so this reflects everything the player did, not just the
  /// moves that actually removed an arrow.
  final int moveCount;

  /// Wrong (blocked) taps so far. The round ends in defeat once this reaches
  /// [CubeMangoScoring.maxMistakes] (the scoring formula is shared with the
  /// Cube 3D mode — it only depends on moves/time/mistakes, not geometry).
  final int mistakes;

  final int elapsedSeconds;

  /// The mango reward for the round, computed once [status] reaches
  /// [HexStatus.victory]. Null otherwise.
  final Score? score;

  /// Why the round ended in defeat (null unless [status] is
  /// [HexStatus.defeat]).
  final DefeatReason? defeatReason;

  /// Ids of arrows whose exit path is currently clear — used to detect
  /// defeat (empty ⇒ no moves left) and, optionally, to highlight them.
  final Set<String> exitableIds;

  /// Arrow that was just tapped but is blocked — flashed for feedback, then
  /// cleared on the next successful move.
  final String? lastBlockedId;

  int get arrowsRemaining => board?.arrowCount ?? 0;

  /// Whether there is a next (harder) level to advance to after this one.
  bool get hasNextLevel => levelIndex + 1 < totalLevels;

  HexGameState copyWith({
    HexStatus? status,
    HexLevel? level,
    BoardState? board,
    int? radius,
    int? levelIndex,
    int? totalLevels,
    int? moveCount,
    int? mistakes,
    int? elapsedSeconds,
    Score? score,
    DefeatReason? defeatReason,
    Set<String>? exitableIds,
    Object? lastBlockedId = _unset,
  }) {
    return HexGameState(
      status: status ?? this.status,
      level: level ?? this.level,
      board: board ?? this.board,
      radius: radius ?? this.radius,
      levelIndex: levelIndex ?? this.levelIndex,
      totalLevels: totalLevels ?? this.totalLevels,
      moveCount: moveCount ?? this.moveCount,
      mistakes: mistakes ?? this.mistakes,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      score: score ?? this.score,
      defeatReason: defeatReason ?? this.defeatReason,
      exitableIds: exitableIds ?? this.exitableIds,
      lastBlockedId:
          identical(lastBlockedId, _unset) ? this.lastBlockedId : lastBlockedId as String?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        level,
        board,
        radius,
        levelIndex,
        totalLevels,
        moveCount,
        mistakes,
        elapsedSeconds,
        score,
        defeatReason,
        exitableIds,
        lastBlockedId,
      ];
}

/// Sentinel distinguishing "not passed" from "explicitly passed null" for
/// [HexGameState.copyWith]'s [HexGameState.lastBlockedId] parameter.
const Object _unset = Object();
