// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:arrowconmango_front/features/game/application/use_cases/load_progress_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/save_local_progress_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/submit_score_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/unlock_next_level_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level_best.dart';
import 'package:arrowconmango_front/features/game/domain/entities/scoring_strategy.dart';
import 'package:arrowconmango_front/features/game/domain/errors/level_not_found_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/progress_event.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/progress_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// {@template progress_bloc}
/// BLoC that manages the player's global progress across levels.
///
/// It receives [ProgressEvent]s from the UI, delegates domain work to the
/// injected use cases, and emits immutable [ProgressState]s.
/// {@endtemplate}
@lazySingleton
class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  /// {@macro progress_bloc}
  ProgressBloc({
    required LoadProgressUseCase loadProgressUseCase,
    required SaveLocalProgressUseCase saveLocalProgressUseCase,
    required UnlockNextLevelUseCase unlockNextLevelUseCase,
    required SubmitScoreUseCase submitScoreUseCase,
    required ScoringStrategy scoringStrategy,
  })  : _loadProgressUseCase = loadProgressUseCase,
        _saveLocalProgressUseCase = saveLocalProgressUseCase,
        _unlockNextLevelUseCase = unlockNextLevelUseCase,
        _submitScoreUseCase = submitScoreUseCase,
        _scoringStrategy = scoringStrategy,
        super(const ProgressInitial()) {
    on<ProgressLoadStarted>(_onProgressLoadStarted);
    on<ProgressLevelCompleted>(_onProgressLevelCompleted);
    on<ProgressUpdatedExternally>(_onProgressUpdatedExternally);
  }

  final LoadProgressUseCase _loadProgressUseCase;
  final SaveLocalProgressUseCase _saveLocalProgressUseCase;
  final UnlockNextLevelUseCase _unlockNextLevelUseCase;
  final SubmitScoreUseCase _submitScoreUseCase;
  final ScoringStrategy _scoringStrategy;

  Future<void> _onProgressLoadStarted(
    ProgressLoadStarted event,
    Emitter<ProgressState> emit,
  ) async {
    // Idempotencia: evita lecturas redundantes si ya tenemos progreso cargado.
    if (state is ProgressLoaded) {
      return;
    }

    emit(const ProgressLoading());

    final result = await _loadProgressUseCase();

    switch (result) {
      case Success(:final value):
        emit(ProgressLoaded(progress: value));
      case Error(:final failure):
        emit(ProgressError(message: failure.message));
    }
  }

  Future<void> _onProgressLevelCompleted(
    ProgressLevelCompleted event,
    Emitter<ProgressState> emit,
  ) async {
    // UX fluida: no bloqueamos la UI con ProgressLoading cuando ya hay progreso.
    final currentProgress = switch (state) {
      ProgressLoaded(:final progress) => progress,
      _ => null,
    };

    if (currentProgress == null) {
      emit(const ProgressError(message: 'Progress not loaded'));
      return;
    }

    // Fire-and-forget: never blocks the unlock/save flow below.
    unawaited(
      _submitScoreUseCase(
        levelId: event.currentLevelId,
        moves: event.moves,
        elapsedSeconds: event.elapsedSeconds,
      ),
    );

    final unlockResult = await _unlockNextLevelUseCase(
      currentLevelId: event.currentLevelId,
    );

    switch (unlockResult) {
      case Success(:final value):
        await _saveBestAndEmit(value, event, emit);

      case Error(:final failure):
        if (failure is LevelNotFoundFailure) {
          // Último nivel: no hay siguiente nivel que desbloquear, pero el
          // mejor tiempo de este nivel se registra igual.
          await _saveBestAndEmit(currentProgress, event, emit);
        } else {
          emit(ProgressError(message: failure.message));
        }
    }
  }

  /// Records [event]'s score as the level's best run (keeping the better of
  /// old/new — see [AppProgress.withBest]), persists it, and emits the
  /// result.
  Future<void> _saveBestAndEmit(
    AppProgress progress,
    ProgressLevelCompleted event,
    Emitter<ProgressState> emit,
  ) async {
    final updatedProgress = progress.withBest(
      event.currentLevelId,
      LevelBest(moves: event.moves, timeElapsedSeconds: event.elapsedSeconds),
      _scoringStrategy,
    );

    final saveResult = await _saveLocalProgressUseCase(
      progress: updatedProgress,
    );

    switch (saveResult) {
      case Success():
        emit(ProgressLoaded(progress: updatedProgress));
      case Error(:final failure):
        emit(ProgressError(message: failure.message));
    }
  }

  void _onProgressUpdatedExternally(
    ProgressUpdatedExternally event,
    Emitter<ProgressState> emit,
  ) {
    emit(ProgressLoaded(progress: event.progress));
  }
}
