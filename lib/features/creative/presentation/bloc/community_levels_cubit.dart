import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../game/domain/repositories/i_creative_level_repository.dart';
import '../../../game/domain/repositories/result.dart';
import 'creative_list_state.dart';

@injectable
class CommunityLevelsCubit extends Cubit<CreativeListState> {
  CommunityLevelsCubit(this._repository) : super(const CreativeListLoading());

  final ICreativeLevelRepository _repository;

  Future<void> load() async {
    emit(const CreativeListLoading());
    final result = await _repository.getCommunityLevels();
    switch (result) {
      case Success(:final value):
        emit(CreativeListLoaded(value));
      case Error(:final failure):
        emit(CreativeListError(failure.message));
    }
  }
}
