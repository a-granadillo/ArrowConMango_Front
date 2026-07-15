// ignore_for_file: prefer_initializing_formals
// Public named parameters are intentionally assigned to private fields in
// the initializer list so the cubit exposes a clean constructor API.

import 'package:arrowconmango_front/core/audio/audio_service.dart';
import 'package:arrowconmango_front/core/audio/sfx_clip.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/trigger_arrow_exit_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_geometry.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:arrowconmango_front/features/game/domain/errors/path_blocked_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/game/domain/services/collision_validator.dart';
import 'package:arrowconmango_front/features/game/domain/services/cube_mango_scoring.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/cube3d/cube3d_game_state.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_state.dart'
    show DefeatReason;
import 'package:flutter_bloc/flutter_bloc.dart';

/// Orchestrates the rotatable-cube "Tap Away" mode.
///
/// Reuses the same domain building blocks as the 2D [GameBloc]
/// ([TriggerArrowExitUseCase], [GameSession], [CollisionValidator]) — only
/// the topology the validator was constructed with differs (a
/// [Grid3DTopology] instead of a `Grid2DTopology`), so no new domain logic
/// is needed for tap-to-exit or blocked-path detection.
///
/// Every tap counts toward [Cube3DGameState.moveCount] — successful exits
/// AND blocked (wrong) attempts alike — and a blocked tap also counts as a
/// mistake; the round ends in defeat once [CubeMangoScoring.maxMistakes] is
/// reached. The mango reward ([Cube3DGameState.score]) is computed from
/// moves, elapsed time and mistakes via [CubeMangoScoring] once the board
/// empties.
class Cube3DGameCubit extends Cubit<Cube3DGameState> {
  Cube3DGameCubit({
    required TriggerArrowExitUseCase triggerArrowExitUseCase,
    required CollisionValidator collisionValidator,
    AudioService? audioService,
    int Function()? clock,
  })  : _triggerArrowExitUseCase = triggerArrowExitUseCase,
        _collisionValidator = collisionValidator,
        _audioService = audioService,
        _clock = clock ?? _defaultClock,
        super(Cube3DGameState.loading);

  final TriggerArrowExitUseCase _triggerArrowExitUseCase;
  final CollisionValidator _collisionValidator;
  final AudioService? _audioService;
  final int Function() _clock;

  static int _defaultClock() => DateTime.now().millisecondsSinceEpoch;

  GameSession? _session;

  /// Starts a fresh session from [level] (a [BoardGeometry3D] level, e.g.
  /// from `CubeLevelGenerator`/`CubeLevels`).
  void load(Level level) {
    final geometry = level.geometry as BoardGeometry3D;
    final board = level.templateBoard;
    _session = GameSession(
      sessionId: 'cube-${level.levelId}-${_clock()}',
      boardState: board,
      startedAtMs: _clock(),
    );

    emit(
      Cube3DGameState(
        status: Cube3DStatus.playing,
        level: level,
        board: board,
        width: geometry.cols,
        height: geometry.rows,
        depth: geometry.depth,
        exitableIds: _computeExitable(board),
      ),
    );
  }

  /// Pumps the elapsed-time display forward. The bloc has no internal
  /// clock — the screen is expected to call this roughly once a second.
  void tick() {
    final session = _session;
    if (session == null || state.status != Cube3DStatus.playing) return;
    final elapsed = session.elapsedSeconds(_clock());
    if (elapsed == state.elapsedSeconds) return;
    emit(state.copyWith(elapsedSeconds: elapsed));
  }

  /// Attempts to slide [arrowId] out. Emits an updated board on success,
  /// bumps [Cube3DGameState.lastBlockedId] if its path is blocked, and
  /// transitions to victory (board empty), or defeat (no moves left, or
  /// [CubeMangoScoring.maxMistakes] mistakes reached).
  void tapArrow(String arrowId) {
    final session = _session;
    if (session == null || state.status != Cube3DStatus.playing) return;

    final attemptedMoveCount = state.moveCount + 1;
    final result = _triggerArrowExitUseCase(session: session, arrowId: arrowId);
    switch (result) {
      case Success(value: final newSession):
        _session = newSession;
        _audioService?.playSfx(SfxClip.arrowExit);
        _emitAfterMove(newSession, moveCount: attemptedMoveCount);
      case Error(failure: final failure):
        if (failure is PathBlockedFailure) {
          _audioService?.playSfx(SfxClip.block);
          _registerMistake(arrowId, moveCount: attemptedMoveCount);
        }
        // ArrowNotFoundFailure / other failures: nothing to reflect in the UI.
    }
  }

  void _registerMistake(String arrowId, {required int moveCount}) {
    final mistakes = state.mistakes + 1;
    final elapsed = _session!.elapsedSeconds(_clock());

    if (mistakes >= CubeMangoScoring.maxMistakes) {
      _audioService?.playSfx(SfxClip.defeat);
      emit(
        state.copyWith(
          status: Cube3DStatus.defeat,
          defeatReason: DefeatReason.outOfLives,
          moveCount: moveCount,
          mistakes: mistakes,
          elapsedSeconds: elapsed,
          lastBlockedId: arrowId,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        moveCount: moveCount,
        mistakes: mistakes,
        elapsedSeconds: elapsed,
        lastBlockedId: arrowId,
      ),
    );
  }

  void _emitAfterMove(GameSession session, {required int moveCount}) {
    final board = session.boardState;
    final elapsed = session.elapsedSeconds(_clock());

    if (board.isEmpty) {
      final score = CubeMangoScoring.calculate(
        moves: moveCount,
        seconds: elapsed,
        mistakes: state.mistakes,
      );
      _audioService?.playSfx(SfxClip.victory);
      emit(
        state.copyWith(
          status: Cube3DStatus.victory,
          board: board,
          moveCount: moveCount,
          elapsedSeconds: elapsed,
          score: score,
          exitableIds: const {},
          lastBlockedId: null,
        ),
      );
      return;
    }

    final exitable = _computeExitable(board);
    if (exitable.isEmpty) {
      _audioService?.playSfx(SfxClip.defeat);
      emit(
        state.copyWith(
          status: Cube3DStatus.defeat,
          defeatReason: DefeatReason.noMovesAvailable,
          board: board,
          moveCount: moveCount,
          elapsedSeconds: elapsed,
          exitableIds: const {},
          lastBlockedId: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        board: board,
        moveCount: moveCount,
        elapsedSeconds: elapsed,
        exitableIds: exitable,
        lastBlockedId: null,
      ),
    );
  }

  Set<String> _computeExitable(BoardState board) {
    final ids = <String>{};
    for (final arrow in board.arrows) {
      if (_collisionValidator.checkExit(arrow, board).canExit) {
        ids.add(arrow.id);
      }
    }
    return ids;
  }

  /// Clears the transient "blocked" flash once its animation has played.
  void clearBlockedFlash() {
    if (state.lastBlockedId != null) emit(state.copyWith(lastBlockedId: null));
  }

  /// Restarts with a newly-generated level (same cube dimensions convention
  /// as the current one is left to the caller).
  void restart(Level freshLevel) => load(freshLevel);
}
