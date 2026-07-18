import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../game/domain/repositories/i_hex_creative_level_repository.dart';
import '../../../game/domain/repositories/result.dart';
import 'hex_creative_list_state.dart';

@injectable
class HexCommunityLevelsCubit extends Cubit<HexCreativeListState> {
  HexCommunityLevelsCubit(this._repository)
      : super(const HexCreativeListLoading());

  final IHexCreativeLevelRepository _repository;

  Future<void> load() async {
    emit(const HexCreativeListLoading());
    final result = await _repository.getCommunityLevels();
    switch (result) {
      case Success(:final value):
        emit(HexCreativeListLoaded(value));
      case Error(:final failure):
        emit(HexCreativeListError(failure.message));
    }
  }
}
