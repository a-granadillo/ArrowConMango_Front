import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../game/domain/repositories/i_hex_creative_level_repository.dart';
import '../../../game/domain/repositories/result.dart';
import 'level_ranking_cubit.dart' show LevelRankingState, LevelRankingLoading, LevelRankingLoaded, LevelRankingError;

/// The hex sibling of [LevelRankingCubit] — reuses [LevelRankingState]
/// as-is (it only carries [LevelRankEntry], which is shape-agnostic),
/// swapping in [IHexCreativeLevelRepository] as the data source.
@injectable
class HexLevelRankingCubit extends Cubit<LevelRankingState> {
  HexLevelRankingCubit(this._repository) : super(const LevelRankingLoading());

  final IHexCreativeLevelRepository _repository;

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
