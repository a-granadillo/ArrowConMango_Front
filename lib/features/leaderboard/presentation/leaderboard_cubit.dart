import 'package:flutter_bloc/flutter_bloc.dart';

import '../../player/domain/guest_player.dart';
import '../domain/i_leaderboard_repository.dart';
import 'leaderboard_state.dart';

/// Loads the global leaderboard for the current guest player.
class LeaderboardCubit extends Cubit<LeaderboardState> {
  LeaderboardCubit({required this._repository})
      : super(const LeaderboardInitial());

  final ILeaderboardRepository _repository;

  Future<void> load(GuestPlayer currentPlayer) async {
    emit(const LeaderboardLoading());
    try {
      final entries =
          await _repository.fetchTopPlayers(currentPlayer: currentPlayer);
      emit(LeaderboardLoaded(entries: entries));
    } catch (e) {
      emit(LeaderboardError(message: 'No se pudo cargar la clasificación: $e'));
    }
  }
}
