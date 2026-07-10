// ignore_for_file: prefer_initializing_formals
// Public named parameters are intentionally assigned to private fields
// in the initializer list so the BLoC exposes a clean constructor API.

import 'package:arrowconmango_front/features/game/application/use_cases/get_level_list_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/menu_event.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/menu_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template menu_bloc}
/// BLoC that orchestrates the main menu's level list.
///
/// It receives [MenuEvent]s from the UI, delegates to
/// [GetLevelListUseCase], and emits immutable [MenuState]s.
/// {@endtemplate}
class MenuBloc extends Bloc<MenuEvent, MenuState> {
  /// {@macro menu_bloc}
  MenuBloc({required GetLevelListUseCase getLevelListUseCase})
      : _getLevelListUseCase = getLevelListUseCase,
        super(const MenuInitial()) {
    on<MenuLevelsRequested>(_onLevelsRequested);
  }

  final GetLevelListUseCase _getLevelListUseCase;

  Future<void> _onLevelsRequested(
    MenuLevelsRequested event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuLoading());

    final result = await _getLevelListUseCase();
    switch (result) {
      case Success(:final value):
        emit(MenuLevelsLoaded(levels: value));
      case Error(:final failure):
        emit(MenuLoadFailure(message: failure.message));
    }
  }
}
