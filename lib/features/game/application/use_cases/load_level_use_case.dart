
import 'package:arrowconmango_front/features/game/data/level_definitions/level_definitions.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/level_mapper.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/level.dart';
import '../../domain/repositories/i_level_repository.dart';

@lazySingleton
class LoadLevelUseCase {
  final ILevelRepository _levelRepository;
  final LevelMapper _levelMapper;

  const LoadLevelUseCase(this._levelRepository, this._levelMapper);

  Future<Result<Level>> call({required int levelId}) async {
    // Si el ID es negativo, es un nivel de supervivencia
    if (levelId < 0) {
      // Usar el valor absoluto del levelId como seed para generar niveles consistentes
      final seed = levelId.abs() * 1000 + 42;
      final endlessLevel = LevelDefinitions.generateEndless(
        id: levelId,
        difficulty: 'Medium',
        seed: seed,
      );
      return Success(_levelMapper.toEntity(endlessLevel));
    }
    
    return await _levelRepository.getLevelDefinition(levelId);
  }
}