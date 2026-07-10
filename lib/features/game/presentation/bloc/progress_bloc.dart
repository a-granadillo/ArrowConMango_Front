// ignore_for_file: prefer_initializing_formals
// Public named parameters are intentionally assigned to private fields
// in the initializer list so the BLoC exposes a clean constructor API.

import 'package:arrowconmango_front/features/game/application/use_cases/load_progress_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/save_local_progress_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/unlock_next_level_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/progress_event.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/progress_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template progress_bloc}
/// BLoC that orchestrates loading, unlocking, and persisting the player's
/// [AppProgress].
///
/// It receives [ProgressEvent]s from the UI (or from [GameBloc] after a
/// victory), delegates domain work to the injected use cases, and emits
/// immutable [ProgressState]s.
/// {@endtemplate}
class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  /// {@macro progress_bloc}
  ProgressBloc({
    required LoadProgressUseCase loadProgressUseCase,
    required UnlockNextLevelUseCase unlockNextLevelUseCase,
    required SaveLocalProgressUseCase saveLocalProgressUseCase,
  })  : _loadProgressUseCase = loadProgressUseCase,
        _unlockNextLevelUseCase = unlockNextLevelUseCase,
        _saveLocalProgressUseCase = saveLocalProgressUseCase,
        super(const ProgressInitial()) {
    on<ProgressRequested>(_onProgressRequested);
    on<ProgressLevelUnlocked>(_onLevelUnlocked);
    on<ProgressSaved>(_onProgressSaved);
  }

  final LoadProgressUseCase _loadProgressUseCase;
  final UnlockNextLevelUseCase _unlockNextLevelUseCase;
  final SaveLocalProgressUseCase _saveLocalProgressUseCase;

  Future<void> _onProgressRequested(
    ProgressRequested event,
    Emitter<ProgressState> emit,
  ) async {
    emit(const ProgressLoading());

    final result = await _loadProgressUseCase();
    switch (result) {
      case Success(:final value):
        emit(ProgressLoaded(progress: value));
      case Error(:final failure):
        emit(ProgressFailure(message: failure.message));
    }
  }

  Future<void> _onLevelUnlocked(
    ProgressLevelUnlocked event,
    Emitter<ProgressState> emit,
  ) async {
    emit(const ProgressLoading());

    // UnlockNextLevelUseCase already persists the updated progress, so no
    // further SaveLocalProgressUseCase call is needed here.
    final result = await _unlockNextLevelUseCase(
      currentLevelId: event.currentLevelId,
    );
    switch (result) {
      case Success(:final value):
        emit(ProgressLoaded(progress: value));
      case Error(:final failure):
        emit(ProgressFailure(message: failure.message));
    }
  }

  Future<void> _onProgressSaved(
    ProgressSaved event,
    Emitter<ProgressState> emit,
  ) async {
    emit(const ProgressLoading());

    final result = await _saveLocalProgressUseCase(progress: event.progress);
    switch (result) {
      case Success<void>():
        emit(ProgressLoaded(progress: event.progress));
      case Error(:final failure):
        emit(ProgressFailure(message: failure.message));
    }
  }
}
