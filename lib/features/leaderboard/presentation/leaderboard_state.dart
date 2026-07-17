import 'package:equatable/equatable.dart';

import '../domain/leaderboard_entry.dart';

/// Which leaderboard tab a [LeaderboardState] refers to.
enum LeaderboardTab { byLevel, survival }

/// States emitted by the [LeaderboardCubit].
sealed class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

final class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();
}

final class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading();
}

final class LeaderboardLoaded extends LeaderboardState {
  const LeaderboardLoaded({
    required this.tab,
    required this.page,
    this.selectedLevelId,
  });

  final LeaderboardTab tab;
  final LeaderboardPage page;

  /// The level currently selected on the "Por Nivel" tab (`null` on the
  /// "Supervivencia" tab).
  final String? selectedLevelId;

  @override
  List<Object?> get props => [tab, page, selectedLevelId];
}

final class LeaderboardError extends LeaderboardState {
  const LeaderboardError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
