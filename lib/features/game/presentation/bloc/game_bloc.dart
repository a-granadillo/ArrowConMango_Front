// ignore_for_file: prefer_initializing_formals
// Public named parameters are intentionally assigned to private fields
// in the initializer list so the BLoC exposes a clean constructor API.

import 'package:arrowconmango_front/features/game/application/dtos/game_evaluation.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/calculate_score_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/evaluate_game_state_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/load_level_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/start_game_session_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/trigger_arrow_exit_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/undo_move_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/unlock_next_level_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:arrowconmango_front/features/game/domain/errors/arrow_not_found_failure.dart';
import 'package:arrowconmango_front/features/game/domain/errors/path_blocked_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/game/domain/services/collision_validator.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_event.dart';
import 'package:flutter/foundation.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_state.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/mappers/game_state_mapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template game_bloc}
/// BLoC that orchestrates the game presentation layer.
///
/// It receives [GameEvent]s from the UI, delegates domain work to the
/// injected use cases, and emits immutable [GameState]s.
/// {@endtemplate}
class GameBloc extends Bloc<GameEvent, GameState> {
  /// {@macro game_bloc}
  GameBloc({
    required LoadLevelUseCase loadLevelUseCase,
    required StartGameSessionUseCase startGameSessionUseCase,
    required EvaluateGameStateUseCase evaluateGameStateUseCase,
    required TriggerArrowExitUseCase triggerArrowExitUseCase,
    required UndoMoveUseCase undoMoveUseCase,
    required CalculateScoreUseCase calculateScoreUseCase,
    required UnlockNextLevelUseCase unlockNextLevelUseCase,
    required CollisionValidator collisionValidator,
    int Function()? clock,
    int timeLimitInSeconds = 60,
  })  : _loadLevelUseCase = loadLevelUseCase,
        _startGameSessionUseCase = startGameSessionUseCase,
        _evaluateGameStateUseCase = evaluateGameStateUseCase,
        _triggerArrowExitUseCase = triggerArrowExitUseCase,
        _undoMoveUseCase = undoMoveUseCase,
        _calculateScoreUseCase = calculateScoreUseCase,
        _unlockNextLevelUseCase = unlockNextLevelUseCase,
        _collisionValidator = collisionValidator,
        _clock = clock ?? _defaultClock,
        _timeLimitInSeconds = timeLimitInSeconds,
        super(const GameInitial()) {
    on<LoadLevel>(_onLoadLevel);
    on<TriggerArrowExit>(_onTriggerArrowExit);
    on<UndoMove>(_onUndoMove);
    on<Tick>(_onTick);
    on<RetryLevel>(_onRetryLevel);
  }

  final LoadLevelUseCase _loadLevelUseCase;
  final StartGameSessionUseCase _startGameSessionUseCase;
  final EvaluateGameStateUseCase _evaluateGameStateUseCase;
  final TriggerArrowExitUseCase _triggerArrowExitUseCase;
  final UndoMoveUseCase _undoMoveUseCase;
  final CalculateScoreUseCase _calculateScoreUseCase;
  final UnlockNextLevelUseCase _unlockNextLevelUseCase;
  final CollisionValidator _collisionValidator;
  final int Function() _clock;
  final int _timeLimitInSeconds;

  static int _defaultClock() => DateTime.now().millisecondsSinceEpoch;

  /// Builds a [Level] from a playing state so the mapper can resolve the
  /// difficulty and level id without relying on mutable bloc fields.
  Level _levelForState(GamePlaying state) {
    return Level(
      levelId: state.levelId,
      rows: state.rows,
      cols: state.cols,
      templateBoard: state.boardState,
    );
  }

  /// Reconstructs a [GameSession] from the current playing state.
  ///
  /// The presentation state is the single source of truth; the session is
  /// rebuilt on demand using the real [CommandHistory] carried by the state.
  GameSession _sessionFromState(GamePlaying state) {
    return GameSession(
      sessionId: 'seeded-session',
      boardState: state.boardState,
      history: state.history,
      moveCount: state.moveCount,
      startedAtMs: state.startedAtMs,
    );
  }

  /// Returns `true` if at least one arrow on the board can exit.
  bool _hasAvailableMoves(BoardState board) {
    if (board.isEmpty) return false;
    for (final arrow in board.arrows) {
      final check = _collisionValidator.checkExit(arrow, board);
      if (check.canExit) return true;
    }
    return false;
  }

  Future<void> _onLoadLevel(LoadLevel event, Emitter<GameState> emit) async {
    emit(GameLoading(levelId: event.levelId));

    final levelResult = await _loadLevelUseCase(levelId: event.levelId);

    switch (levelResult) {
      case Success(value: final level):
        final nowMs = _clock();
        final sessionResult = _startGameSessionUseCase(
          level: level,
          sessionId: 'session-${event.levelId}',
          startedAtMs: nowMs,
        );

        switch (sessionResult) {
          case Success(value: final session):
            await _emitPlayingState(session, level, emit);
          case Error(failure: final failure):
            emit(GameError(message: failure.message, levelId: event.levelId));
        }
      case Error(failure: final failure):
        emit(GameError(message: failure.message, levelId: event.levelId));
    }
  }

  Future<void> _onTriggerArrowExit(
    TriggerArrowExit event,
    Emitter<GameState> emit,
  ) async {
    final state = this.state;
    if (state is! GamePlaying) return;

    final session = _sessionFromState(state);
    final result = _triggerArrowExitUseCase(
      session: session,
      arrowId: event.arrowId,
    );

    switch (result) {
      case Success(value: final newSession):
        final evaluation = _evaluateGameStateUseCase(
          session: newSession,
          nowMs: _clock(),
        );
        final level = _levelForState(state);

        if (evaluation.status == GameStatus.victory) {
          await _emitVictoryState(newSession, evaluation, level, emit);
          return;
        }

        if (!newSession.boardState.isEmpty &&
            !_hasAvailableMoves(newSession.boardState)) {
          emit(
            GameStateMapper.mapToDefeatState(
              session: newSession,
              level: level,
              reason: DefeatReason.noMovesAvailable,
              nowMs: _clock(),
            ),
          );
          return;
        }

        _emitPlayingStateFromEvaluation(newSession, level, evaluation, emit);
      case Error(failure: final failure):
        if (failure is ArrowNotFoundFailure || failure is PathBlockedFailure) {
          // Expected domain errors: keep the UI in GamePlaying.
          break;
        }
        emit(GameError(message: failure.message));
    }
  }

  Future<void> _onUndoMove(UndoMove event, Emitter<GameState> emit) async {
    final state = this.state;
    if (state is! GamePlaying) return;

    final session = _sessionFromState(state);
    final result = _undoMoveUseCase(session: session);

    switch (result) {
      case Success(value: final newSession):
        final evaluation = _evaluateGameStateUseCase(
          session: newSession,
          nowMs: _clock(),
        );
        _emitPlayingStateFromEvaluation(
          newSession,
          _levelForState(state),
          evaluation,
          emit,
        );
      case Error():
        // No moves to undo: keep the current state unchanged.
        break;
    }
  }

  Future<void> _onTick(Tick event, Emitter<GameState> emit) async {
    final state = this.state;
    if (state is! GamePlaying) return;

    final session = _sessionFromState(state);
    final evaluation = _evaluateGameStateUseCase(
      session: session,
      nowMs: event.nowMs,
    );

    if (evaluation.elapsedSeconds == state.elapsedSeconds) {
      // Same second: skip emitting to avoid unnecessary re-renders.
      return;
    }

    if (evaluation.elapsedSeconds >= _timeLimitInSeconds) {
      emit(
        GameStateMapper.mapToDefeatState(
          session: session,
          level: _levelForState(state),
          reason: DefeatReason.timeExpired,
          nowMs: event.nowMs,
        ),
      );
      return;
    }

    _emitPlayingStateFromEvaluation(
      session,
      _levelForState(state),
      evaluation,
      emit,
    );
  }

  Future<void> _onRetryLevel(RetryLevel event, Emitter<GameState> emit) async {
    final state = this.state;
    final levelId = switch (state) {
      GamePlaying(:final levelId) => levelId,
      GameDefeat(:final levelId) => levelId,
      GameVictory(:final levelId) => levelId,
      _ => null,
    };

    if (levelId == null) return;

    emit(GameLoading(levelId: levelId));

    final levelResult = await _loadLevelUseCase(levelId: levelId);

    switch (levelResult) {
      case Success(value: final level):
        final nowMs = _clock();
        final sessionResult = _startGameSessionUseCase(
          level: level,
          sessionId: 'session-$levelId',
          startedAtMs: nowMs,
        );

        switch (sessionResult) {
          case Success(value: final session):
            await _emitPlayingState(session, level, emit);
          case Error(failure: final failure):
            emit(GameError(message: failure.message, levelId: levelId));
        }
      case Error(failure: final failure):
        emit(GameError(message: failure.message, levelId: levelId));
    }
  }

  Future<void> _emitPlayingState(
    GameSession session,
    Level level,
    Emitter<GameState> emit,
  ) async {
    final nowMs = _clock();
    final evaluation = _evaluateGameStateUseCase(
      session: session,
      nowMs: nowMs,
    );
    _emitPlayingStateFromEvaluation(session, level, evaluation, emit);
  }

  void _emitPlayingStateFromEvaluation(
    GameSession session,
    Level level,
    GameEvaluation evaluation,
    Emitter<GameState> emit,
  ) {
    // Align the mapper clock with the elapsed time reported by the evaluation
    // so the emitted state reflects the evaluated elapsed seconds.
    final nowMs = session.startedAtMs + (evaluation.elapsedSeconds * 1000);
    emit(
      GameStateMapper.mapToPlayingState(
        session: session,
        level: level,
        score: evaluation.score,
        nowMs: nowMs,
      ),
    );
  }

  Future<void> _emitVictoryState(
    GameSession session,
    GameEvaluation evaluation,
    Level level,
    Emitter<GameState> emit,
  ) async {
    final scoreResult = _calculateScoreUseCase(
      moves: evaluation.moveCount,
      elapsedSeconds: evaluation.elapsedSeconds,
    );

    switch (scoreResult) {
      case Success(value: final score):
        final unlockResult = await _unlockNextLevelUseCase(
          currentLevelId: level.levelId,
        );
        final nowMs = session.startedAtMs + (evaluation.elapsedSeconds * 1000);
        emit(
          GameStateMapper.mapToVictoryState(
            session: session,
            level: level,
            score: score,
            nowMs: nowMs,
          ),
        );
        if (unlockResult case Error(failure: final failure)) {
          debugPrint('Warning: Failed to unlock next level: ${failure.message}');
        }
      case Error(failure: final failure):
        emit(GameError(message: failure.message));
    }
  }
}
