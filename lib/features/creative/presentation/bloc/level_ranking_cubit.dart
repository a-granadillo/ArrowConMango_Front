import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../game/domain/entities/level_rank_entry.dart';
import '../../../game/domain/repositories/i_creative_level_repository.dart';
import '../../../game/domain/repositories/result.dart';

sealed class LevelRankingState extends Equatable {
  const LevelRankingState();
  @override
  List<Object?> get props => [];
}

class LevelRankingLoading extends LevelRankingState {
  const LevelRankingLoading();
}

class LevelRankingLoaded extends LevelRankingState {
  const LevelRankingLoaded(this.entries);
  final List<LevelRankEntry> entries;
  @override
  List<Object?> get props => [entries];
}

class LevelRankingError extends LevelRankingState {
  const LevelRankingError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

@injectable
class LevelRankingCubit extends Cubit<LevelRankingState> {
  LevelRankingCubit(this._repository) : super(const LevelRankingLoading());

  final ICreativeLevelRepository _repository;

  Future<void> load(String levelId) async {
    emit(const LevelRankingLoading());
    final result = await _repository.getLevelRanking(levelId);
    switch (result) {
      case Success(:final value):
        emit(LevelRankingLoaded(value));
      case Error(:final failure):
        emit(LevelRankingError(failure.message));
    }
  }
}
