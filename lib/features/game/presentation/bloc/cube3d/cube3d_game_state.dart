import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:arrowconmango_front/features/game/domain/entities/score.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_state.dart'
    show DefeatReason;
import 'package:equatable/equatable.dart';

enum Cube3DStatus { loading, playing, victory, defeat }

/// State for [Cube3DGameCubit] — the rotatable-cube "Tap Away" mode.
///
/// A single flat class (rather than sealed subclasses like [GameState])
/// since every field but [level]/[board] is meaningful across all statuses
/// and the UI only reads them once [status] has left [Cube3DStatus.loading].
class Cube3DGameState extends Equatable {
  const Cube3DGameState({
    required this.status,
    this.level,
    this.board,
    this.width = 0,
    this.height = 0,
    this.depth = 0,
    this.moveCount = 0,
    this.mistakes = 0,
    this.elapsedSeconds = 0,
    this.score,
    this.defeatReason,
    this.exitableIds = const {},
    this.lastBlockedId,
  });

  static const loading = Cube3DGameState(status: Cube3DStatus.loading);

  final Cube3DStatus status;
  final Level? level;
  final BoardState? board;
  final int width;
  final int height;
  final int depth;

  /// Total taps attempted — successful exits AND blocked (wrong) attempts
  /// both count, so this reflects everything the player did, not just the
  /// moves that actually removed an arrow.
  final int moveCount;

  /// Wrong (blocked) taps so far. The round ends in defeat once this reaches
  /// [CubeMangoScoring.maxMistakes].
  final int mistakes;

  final int elapsedSeconds;

  /// The mango reward for the round, computed via [CubeMangoScoring] once
  /// [status] reaches [Cube3DStatus.victory]. Null otherwise.
  final Score? score;

  /// Why the round ended in defeat (null unless [status] is
  /// [Cube3DStatus.defeat]).
  final DefeatReason? defeatReason;

  /// Ids of arrows whose exit path is currently clear — used to detect
  /// defeat (empty ⇒ no moves left) and, optionally, to highlight them.
  final Set<String> exitableIds;

  /// Arrow that was just tapped but is blocked — flashed for feedback, then
  /// cleared on the next successful move.
  final String? lastBlockedId;

  int get arrowsRemaining => board?.arrowCount ?? 0;

  Cube3DGameState copyWith({
    Cube3DStatus? status,
    Level? level,
    BoardState? board,
    int? width,
    int? height,
    int? depth,
    int? moveCount,
    int? mistakes,
    int? elapsedSeconds,
    Score? score,
    DefeatReason? defeatReason,
    Set<String>? exitableIds,
    Object? lastBlockedId = _unset,
  }) {
    return Cube3DGameState(
      status: status ?? this.status,
      level: level ?? this.level,
      board: board ?? this.board,
      width: width ?? this.width,
      height: height ?? this.height,
      depth: depth ?? this.depth,
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
        width,
        height,
        depth,
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
/// [Cube3DGameState.copyWith]'s [Cube3DGameState.lastBlockedId] parameter.
const Object _unset = Object();
