// ignore_for_file: prefer_initializing_formals
// Public named parameters are intentionally assigned to private fields in
// the initializer list so the cubit exposes a clean constructor API.

import 'package:arrowconmango_front/core/audio/audio_service.dart';
import 'package:arrowconmango_front/core/audio/sfx_clip.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/trigger_arrow_exit_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/entities/hex_level.dart';
import 'package:arrowconmango_front/features/game/domain/errors/path_blocked_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_hex_level_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/game/domain/services/collision_validator.dart';
import 'package:arrowconmango_front/features/game/domain/services/cube_mango_scoring.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_state.dart'
    show DefeatReason;
import 'package:arrowconmango_front/features/game/presentation/bloc/hex/hex_game_state.dart';
import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:flutter_bloc/flutter_bloc.dart';

/// Orchestrates the hexagonal-board mode: a sequence of levels of
/// progressively increasing difficulty (like Campaign), on a hex-shaped
/// board instead of a rectangular grid.
///
/// Reuses the same domain building blocks as the 2D [GameBloc] and
/// [Cube3DGameCubit] ([TriggerArrowExitUseCase], [GameSession],
/// [CollisionValidator]) — only the topology the validator was constructed
/// with differs (a `HexTopology` instead of `Grid2DTopology`/`Grid3DTopology`),
/// so no new domain logic is needed for tap-to-exit or blocked-path
/// detection. Scoring reuses [CubeMangoScoring] (moves/time/mistakes only,
/// no geometry dependency).
///
/// Every tap counts toward [HexGameState.moveCount] — successful exits AND
/// blocked (wrong) attempts alike — and a blocked tap also counts as a
/// mistake; the round ends in defeat once [CubeMangoScoring.maxMistakes] is
/// reached. On victory, the score is submitted to the hexagonal-mode
/// leaderboard best-effort (see [IHexLevelRepository.submitScore]).
class HexGameCubit extends Cubit<HexGameState> {
  HexGameCubit({
    required TriggerArrowExitUseCase triggerArrowExitUseCase,
    required CollisionValidator collisionValidator,
    required IHexLevelRepository hexLevelRepository,
    AudioService? audioService,
    int Function()? clock,
  })  : _triggerArrowExitUseCase = triggerArrowExitUseCase,
        _collisionValidator = collisionValidator,
        _hexLevelRepository = hexLevelRepository,
        _audioService = audioService,
        _clock = clock ?? _defaultClock,
        super(HexGameState.loading);

  final TriggerArrowExitUseCase _triggerArrowExitUseCase;
  final CollisionValidator _collisionValidator;
  final IHexLevelRepository _hexLevelRepository;
  final AudioService? _audioService;
  final int Function() _clock;

  static int _defaultClock() => DateTime.now().millisecondsSinceEpoch;

  GameSession? _session;
  List<HexLevel> _levels = const [];

  /// Whether the current session is a one-off external play (test-play from
  /// the editor, or a single community level) rather than progression
  /// through the catalogue — see [loadExternal].
  bool _isTestPlay = false;

  /// Callback for a test-play session (set via [loadExternal]'s [onSolved]),
  /// invoked on victory *instead of* submitting a leaderboard score — a
  /// draft/community single-level test-play has no meaningful score to
  /// submit against its own id the way catalogue progression does.
  VoidCallback? _onExternalSolved;

  /// Fetches the hexagonal catalogue (remote-first, local-fallback — see
  /// [IHexLevelRepository]) and starts the first level.
  Future<void> loadLevels() async {
    emit(HexGameState.loading);
    _isTestPlay = false;
    _onExternalSolved = null;
    final result = await _hexLevelRepository.getLevels();
    switch (result) {
      case Success(value: final levels):
        _levels = levels;
        _startLevel(0);
      case Error():
        _levels = const [];
        emit(
          const HexGameState(
            status: HexStatus.defeat,
            defeatReason: DefeatReason.noMovesAvailable,
          ),
        );
    }
  }

  /// Plays a single [level] outside the catalogue's progression — used for
  /// creative-mode test-play (pass [onSolved] so victory calls it instead of
  /// submitting a score, mirroring `LevelEditorCubit.markSolved`) and for
  /// playing a single published community hex level (omit [onSolved]: a
  /// normal victory submits the score against the level's own ranking, like
  /// catalogue play).
  void loadExternal(HexLevel level, {VoidCallback? onSolved}) {
    _isTestPlay = onSolved != null;
    _onExternalSolved = onSolved;
    _levels = [level];
    _startLevel(0);
  }

  void _startLevel(int index) {
    if (index < 0 || index >= _levels.length) return;
    final level = _levels[index];
    final board = level.templateBoard;
    _session = GameSession(
      sessionId: 'hex-${level.id}-${_clock()}',
      boardState: board,
      startedAtMs: _clock(),
    );

    emit(
      HexGameState(
        status: HexStatus.playing,
        level: level,
        board: board,
        radius: level.radius,
        levelIndex: index,
        totalLevels: _levels.length,
        exitableIds: _computeExitable(board),
      ),
    );
  }

  /// Pumps the elapsed-time display forward. The cubit has no internal
  /// clock — the screen is expected to call this roughly once a second.
  void tick() {
    final session = _session;
    if (session == null || state.status != HexStatus.playing) return;
    final elapsed = session.elapsedSeconds(_clock());
    if (elapsed == state.elapsedSeconds) return;
    emit(state.copyWith(elapsedSeconds: elapsed));
  }

  /// Attempts to slide [arrowId] out. Emits an updated board on success,
  /// bumps [HexGameState.lastBlockedId] if its path is blocked, and
  /// transitions to victory (board empty), or defeat (no moves left, or
  /// [CubeMangoScoring.maxMistakes] mistakes reached).
  void tapArrow(String arrowId) {
    final session = _session;
    if (session == null || state.status != HexStatus.playing) return;

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
          _registerMistake(
            arrowId,
            blockingArrowId: failure.blockingArrowId,
            moveCount: attemptedMoveCount,
          );
        }
        // ArrowNotFoundFailure / other failures: nothing to reflect in the UI.
    }
  }

  void _registerMistake(
    String arrowId, {
    required String blockingArrowId,
    required int moveCount,
  }) {
    final mistakes = state.mistakes + 1;
    final elapsed = _session!.elapsedSeconds(_clock());

    if (mistakes >= CubeMangoScoring.maxMistakes) {
      _audioService?.playSfx(SfxClip.defeat);
      emit(
        state.copyWith(
          status: HexStatus.defeat,
          defeatReason: DefeatReason.outOfLives,
          moveCount: moveCount,
          mistakes: mistakes,
          elapsedSeconds: elapsed,
          lastBlockedId: arrowId,
          lastBlockingId: blockingArrowId,
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
        lastBlockingId: blockingArrowId,
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
          status: HexStatus.victory,
          board: board,
          moveCount: moveCount,
          elapsedSeconds: elapsed,
          score: score,
          exitableIds: const {},
          lastBlockedId: null,
          lastBlockingId: null,
        ),
      );
      if (_isTestPlay) {
        _onExternalSolved?.call();
      } else {
        final level = state.level;
        if (level != null) {
          // Fire-and-forget: a failed submission has no meaningful UI
          // recovery here (see SubmitScoreUseCase / VictoryScreen's
          // community-level path).
          _hexLevelRepository.submitScore(
            levelId: level.id,
            moves: moveCount,
            elapsedSeconds: elapsed,
          );
        }
      }
      return;
    }

    final exitable = _computeExitable(board);
    if (exitable.isEmpty) {
      _audioService?.playSfx(SfxClip.defeat);
      emit(
        state.copyWith(
          status: HexStatus.defeat,
          defeatReason: DefeatReason.noMovesAvailable,
          board: board,
          moveCount: moveCount,
          elapsedSeconds: elapsed,
          exitableIds: const {},
          lastBlockedId: null,
          lastBlockingId: null,
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
        lastBlockingId: null,
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
    if (state.lastBlockedId != null) {
      emit(state.copyWith(lastBlockedId: null, lastBlockingId: null));
    }
  }

  /// Advances to the next (harder) level, if any — see
  /// [HexGameState.hasNextLevel]. No-op if the catalogue is exhausted.
  void nextLevel() {
    if (!state.hasNextLevel) return;
    _startLevel(state.levelIndex + 1);
  }

  /// Restarts the current level from scratch.
  void retryLevel() => _startLevel(state.levelIndex);
}
