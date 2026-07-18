import 'package:equatable/equatable.dart';

import '../domain/leaderboard_entry.dart';

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
  const LeaderboardLoaded({required this.entries});

  final List<LeaderboardEntry> entries;

  @override
  List<Object?> get props => [entries];
}

final class LeaderboardError extends LeaderboardState {
  const LeaderboardError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
