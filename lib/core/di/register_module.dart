import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../features/game/application/use_cases/trigger_arrow_exit_use_case.dart';
import '../../features/game/data/models/app_progress_model.dart';
import '../../features/game/data/models/level_model.dart';
import '../../features/game/data/topologies/grid_2d_topology.dart';
import '../../features/game/data/topologies/grid_3d_topology.dart';
import '../../features/game/data/topologies/hex_topology.dart';
import '../../features/game/domain/services/collision_validator.dart';
import '../../features/game/domain/services/move_based_scoring.dart';
import '../../features/game/domain/entities/scoring_strategy.dart';
import '../../features/player/data/player_local_data_source.dart';
import '../audio/audio_settings_local_data_source.dart';
import '../database/hive_config.dart';

/// Module that registers runtime dependencies which cannot be annotated
/// directly (third-party classes, Hive boxes and dimension-dependent domain
/// services).
@module
abstract class RegisterModule {
  @lazySingleton
  Box<LevelModel> get levelsBox =>
      Hive.box<LevelModel>(HiveConfig.levelsBoxName);

  @lazySingleton
  Box<AppProgressModel> get progressBox =>
      Hive.box<AppProgressModel>(HiveConfig.progressBoxName);

  @Named('playerBox')
  @lazySingleton
  Box<dynamic> get playerBox =>
      Hive.box<dynamic>(PlayerLocalDataSource.boxName);

  @Named('audioBox')
  @lazySingleton
  Box<dynamic> get audioBox =>
      Hive.box<dynamic>(AudioSettingsLocalDataSource.boxName);

  @lazySingleton
  Dio get dio => Dio();

  @lazySingleton
  Connectivity get connectivity => Connectivity();

  @lazySingleton
  ScoringStrategy get scoringStrategy => const MoveBasedScoring();

  @lazySingleton
  CollisionValidator get collisionValidator {
    final box = Hive.box<LevelModel>(HiveConfig.levelsBoxName);
    final maxSize = _maxBoardSize(box);
    return CollisionValidator(
      Grid2DTopology(rows: maxSize, cols: maxSize),
    );
  }

  @Named('cube3d')
  @lazySingleton
  CollisionValidator get cube3dCollisionValidator => CollisionValidator(
        Grid3DTopology(width: 6, height: 6, depth: 6),
      );

  @Named('cube3d')
  @lazySingleton
  TriggerArrowExitUseCase cube3dTriggerArrowExitUseCase(
    @Named('cube3d') CollisionValidator validator,
  ) =>
      TriggerArrowExitUseCase(validator);

  /// Fixed board radius (like the cube's fixed 6x6x6), large enough to cover
  /// every level in [HexLevels] (max radius 3) plus headroom for the remote
  /// catalogue.
  @Named('hex')
  @lazySingleton
  CollisionValidator get hexCollisionValidator =>
      CollisionValidator(HexTopology(radius: 4));

  @Named('hex')
  @lazySingleton
  TriggerArrowExitUseCase hexTriggerArrowExitUseCase(
    @Named('hex') CollisionValidator validator,
  ) =>
      TriggerArrowExitUseCase(validator);

  static int _maxBoardSize(Box<LevelModel> levelsBox) {
    var maxDim = 1;
    for (final level in levelsBox.values) {
      maxDim = math.max(
        maxDim,
        math.max(level.boardSize.rows, level.boardSize.cols),
      );
    }
    return maxDim;
  }
}
