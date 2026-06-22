
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';

import '../../domain/entities/level.dart';
import '../../domain/repositories/i_level_repository.dart';

class LoadLevelUseCase {
  final ILevelRepository _levelRepository;

  const LoadLevelUseCase(this._levelRepository);

  Future<Result<Level>> call({required int levelId}) async {
    return await _levelRepository.getLevelDefinition(levelId);
  }
}