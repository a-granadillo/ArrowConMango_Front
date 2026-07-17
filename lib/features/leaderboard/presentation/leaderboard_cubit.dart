// ignore_for_file: prefer_initializing_formals

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../domain/i_leaderboard_repository.dart';
import 'leaderboard_state.dart';

/// Loads either tab of the leaderboard ("Por Nivel" or "Supervivencia").
///
/// Caches the last loaded page per tab so switching tabs back and forth
/// doesn't refetch — only [loadByLevel] with a new [levelId] or an explicit
/// [refresh] hits the network again.
@injectable
class LeaderboardCubit extends Cubit<LeaderboardState> {
  LeaderboardCubit({required ILeaderboardRepository repository})
      : _repository = repository,
        super(const LeaderboardInitial());

  final ILeaderboardRepository _repository;
  final Map<String, LeaderboardLoaded> _byLevelCache = {};
  LeaderboardLoaded? _survivalCache;

  Future<void> loadByLevel(String levelId, {bool refresh = false}) async {
    final cached = _byLevelCache[levelId];
    if (!refresh && cached != null) {
      emit(cached);
      return;
    }

    emit(const LeaderboardLoading());
    try {
      final page = await _repository.fetchByLevel(levelId: levelId);
      final loaded = LeaderboardLoaded(
        tab: LeaderboardTab.byLevel,
        page: page,
        selectedLevelId: levelId,
      );
      _byLevelCache[levelId] = loaded;
      emit(loaded);
    } catch (e) {
      emit(LeaderboardError(message: 'No se pudo cargar la clasificación: $e'));
    }
  }

  Future<void> loadSurvival({bool refresh = false}) async {
    if (!refresh && _survivalCache != null) {
      emit(_survivalCache!);
      return;
    }

    emit(const LeaderboardLoading());
    try {
      final page = await _repository.fetchSurvival();
      final loaded = LeaderboardLoaded(tab: LeaderboardTab.survival, page: page);
      _survivalCache = loaded;
      emit(loaded);
    } catch (e) {
      emit(LeaderboardError(message: 'No se pudo cargar la clasificación: $e'));
    }
  }
}
