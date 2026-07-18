// ignore_for_file: prefer_initializing_formals

import 'package:arrowconmango_front/features/game/application/use_cases/get_level_list_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/menu_event.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/menu_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// {@template menu_bloc}
/// BLoC that provides the list of levels with their unlock state for the
/// level selection screen.
///
/// It receives [MenuEvent]s from the UI, delegates domain work to the
/// injected use case, and emits immutable [MenuState]s.
/// {@endtemplate}
@injectable
class MenuBloc extends Bloc<MenuEvent, MenuState> {
  /// {@macro menu_bloc}
  MenuBloc({
    required GetLevelListUseCase getLevelListUseCase,
  })  : _getLevelListUseCase = getLevelListUseCase,
        super(const MenuInitial()) {
    on<MenuLevelsRequested>(_onMenuLevelsRequested);
    on<MenuLevelsRefreshed>(_onMenuLevelsRefreshed);
  }

  final GetLevelListUseCase _getLevelListUseCase;

  Future<void> _onMenuLevelsRequested(
    MenuLevelsRequested event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuLoading());
    await _loadLevels(emit);
  }

  Future<void> _onMenuLevelsRefreshed(
    MenuLevelsRefreshed event,
    Emitter<MenuState> emit,
  ) async {
    // Refresco silencioso: nunca emite MenuLoading.
    await _loadLevels(emit);
  }

  Future<void> _loadLevels(Emitter<MenuState> emit) async {
    final result = await _getLevelListUseCase();

    switch (result) {
      case Success(:final value):
        emit(MenuLoaded(levels: value));
      case Error(:final failure):
        emit(MenuError(message: failure.message));
    }
  }
}
