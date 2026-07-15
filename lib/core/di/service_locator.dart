import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../features/game/application/use_cases/calculate_score_use_case.dart';
import '../../features/game/application/use_cases/evaluate_game_state_use_case.dart';
import '../../features/game/application/use_cases/get_level_definition_use_case.dart';
import '../../features/game/application/use_cases/get_level_list_use_case.dart';
import '../../features/game/application/use_cases/load_level_use_case.dart';
import '../../features/game/application/use_cases/load_progress_use_case.dart';
import '../../features/game/application/use_cases/save_local_progress_use_case.dart';
import '../../features/game/application/use_cases/start_game_session_use_case.dart';
import '../../features/game/application/use_cases/trigger_arrow_exit_use_case.dart';
import '../../features/game/application/use_cases/undo_move_use_case.dart';
import '../../features/game/application/use_cases/unlock_next_level_use_case.dart';
import '../../features/game/data/datasources/remote_progress_data_source.dart';
import '../../features/game/data/level_definitions/level_definitions.dart';
import '../../features/game/data/models/app_progress_model.dart';
import '../../features/game/data/models/level_model.dart';
import '../../features/game/data/models/mappers/app_progress_mapper.dart';
import '../../features/game/data/models/mappers/arrow_mapper.dart';
import '../../features/game/data/models/mappers/board_state_mapper.dart';
import '../../features/game/data/models/mappers/level_mapper.dart';
import '../../features/game/data/repositories/hive_level_repository.dart';
import '../../features/game/data/repositories/hive_progress_repository.dart';
import '../../features/game/data/repositories/synced_progress_repository.dart';
import '../../features/game/data/topologies/grid_2d_topology.dart';
import '../../features/game/domain/repositories/i_level_repository.dart';
import '../../features/game/domain/repositories/i_progress_repository.dart';
import '../../features/game/domain/services/collision_validator.dart';
import '../../features/game/domain/entities/scoring_strategy.dart' as scoring;
import '../../features/game/domain/services/move_based_scoring.dart';
import '../../features/game/presentation/bloc/game_bloc.dart';
import '../../features/game/presentation/bloc/menu_bloc.dart';
import '../../features/game/presentation/bloc/progress_bloc.dart';
import '../../features/leaderboard/data/mock_leaderboard_repository.dart';
import '../../features/leaderboard/domain/i_leaderboard_repository.dart';
import '../../features/leaderboard/presentation/leaderboard_cubit.dart';
import '../../features/player/data/auth_token_store.dart';
import '../../features/player/data/guest_name_generator.dart';
import '../../features/player/data/player_local_data_source.dart';
import '../../features/player/domain/guest_player.dart';
import '../../features/player/presentation/player_cubit.dart';
import '../audio/audio_service.dart';
import '../audio/audio_service_impl.dart';
import '../audio/audio_settings_cubit.dart';
import '../audio/audio_settings_local_data_source.dart';
import '../database/hive_config.dart';
import '../network/api_client.dart';
import '../network/auth_interceptor.dart';
import 'progress_seed.dart';

/// Global service locator (composition root).
final GetIt sl = GetIt.instance;

/// Wires the whole object graph and seeds local data.
///
/// Requires [HiveConfig.initialise] to have run first (levels/progress boxes
/// open). Opens the player box, seeds the levels box on first launch, and
/// registers repositories, use cases, services and BLoCs.
Future<void> setupServiceLocator() async {
  // --- Hive boxes ---
  final levelsBox = Hive.box<LevelModel>(HiveConfig.levelsBoxName);
  final progressBox = Hive.box<AppProgressModel>(HiveConfig.progressBoxName);
  final playerBox = await Hive.openBox<dynamic>(PlayerLocalDataSource.boxName);

  _seedLevels(levelsBox);
  seedProgressIfEmpty(progressBox);

  // --- Player (Guest-First identity) ---
  // Wired early: the auth interceptor needs the guest uuid to log in.
  final nameGenerator = GuestNameGenerator();
  final playerDataSource = PlayerLocalDataSource(
    box: playerBox,
    nameGenerator: nameGenerator,
  );
  final GuestPlayer initialPlayer = playerDataSource.getOrCreate();
  sl
    ..registerSingleton<PlayerLocalDataSource>(playerDataSource)
    ..registerSingleton<PlayerCubit>(
      PlayerCubit(dataSource: playerDataSource, initial: initialPlayer),
    );

  // --- Networking ---
  sl
    ..registerLazySingleton<AuthTokenStore>(
      () => AuthTokenStore(box: playerBox),
    )
    ..registerLazySingleton<AuthInterceptor>(
      () => AuthInterceptor(
        tokenStore: sl<AuthTokenStore>(),
        guestUuid: initialPlayer.uuid,
      ),
    )
    ..registerLazySingleton<ApiClient>(
      () => ApiClient(authInterceptor: sl<AuthInterceptor>()),
    )
    ..registerLazySingleton<Connectivity>(Connectivity.new)
    ..registerLazySingleton<RemoteProgressDataSource>(
      () => RemoteProgressDataSource(sl<ApiClient>().dio),
    );

  // --- Mappers ---
  sl
    ..registerLazySingleton<ArrowMapper>(ArrowMapper.new)
    ..registerLazySingleton<BoardStateMapper>(
      () => BoardStateMapper(sl<ArrowMapper>()),
    )
    ..registerLazySingleton<LevelMapper>(
      () => LevelMapper(sl<BoardStateMapper>()),
    )
    ..registerLazySingleton<AppProgressMapper>(AppProgressMapper.new);

  // --- Repositories ---
  sl
    ..registerLazySingleton<ILevelRepository>(
      () => HiveLevelRepository(levelsBox, sl<LevelMapper>()),
    )
    ..registerLazySingleton<HiveProgressRepository>(
      () => HiveProgressRepository(progressBox, sl<AppProgressMapper>()),
    )
    ..registerLazySingleton<IProgressRepository>(
      () => SyncedProgressRepository(
        local: sl<HiveProgressRepository>(),
        remote: sl<RemoteProgressDataSource>(),
        mapper: sl<AppProgressMapper>(),
        connectivity: sl<Connectivity>(),
        pendingFlagBox: playerBox,
      ),
    );

  // --- Domain services ---
  final maxSize = _maxBoardSize(levelsBox);
  sl
    ..registerLazySingleton<scoring.ScoringStrategy>(MoveBasedScoring.new)
    ..registerLazySingleton<CollisionValidator>(
      () => CollisionValidator(Grid2DTopology(rows: maxSize, cols: maxSize)),
    );

  // --- Use cases ---
  sl
    ..registerLazySingleton<LoadLevelUseCase>(
      () => LoadLevelUseCase(sl<ILevelRepository>(), sl<LevelMapper>()),
    )
    ..registerLazySingleton<GetLevelDefinitionUseCase>(
      () => GetLevelDefinitionUseCase(sl<ILevelRepository>()),
    )
    ..registerLazySingleton<GetLevelListUseCase>(
      () => GetLevelListUseCase(
        sl<ILevelRepository>(),
        sl<IProgressRepository>(),
      ),
    )
    ..registerLazySingleton<StartGameSessionUseCase>(
      StartGameSessionUseCase.new,
    )
    ..registerLazySingleton<EvaluateGameStateUseCase>(
      () => EvaluateGameStateUseCase(sl<scoring.ScoringStrategy>()),
    )
    ..registerLazySingleton<TriggerArrowExitUseCase>(
      () => TriggerArrowExitUseCase(sl<CollisionValidator>()),
    )
    ..registerLazySingleton<UndoMoveUseCase>(UndoMoveUseCase.new)
    ..registerLazySingleton<CalculateScoreUseCase>(
      () => CalculateScoreUseCase(sl<scoring.ScoringStrategy>()),
    )
    ..registerLazySingleton<UnlockNextLevelUseCase>(
      () => UnlockNextLevelUseCase(
        sl<IProgressRepository>(),
        sl<ILevelRepository>(),
      ),
    )
    ..registerLazySingleton<LoadProgressUseCase>(
      () => LoadProgressUseCase(sl<IProgressRepository>()),
    )
    ..registerLazySingleton<SaveLocalProgressUseCase>(
      () => SaveLocalProgressUseCase(sl<IProgressRepository>()),
    );

  // --- Audio ---
  final audioBox = await Hive.openBox<dynamic>(
    AudioSettingsLocalDataSource.boxName,
  );
  final audioSettings = AudioSettingsLocalDataSource(box: audioBox);
  final audioService = AudioServiceImpl(settings: audioSettings);
  sl
    ..registerSingleton<AudioSettingsLocalDataSource>(audioSettings)
    ..registerSingleton<AudioService>(
      audioService,
      dispose: (service) => service.dispose(),
    )
    ..registerSingleton<AudioSettingsCubit>(
      AudioSettingsCubit(service: audioService),
      dispose: (cubit) => cubit.close(),
    );

  // --- BLoCs ---
  // Global, shared across the app (progress unlocks must propagate).
  sl.registerLazySingleton<ProgressBloc>(
    () => ProgressBloc(
      loadProgressUseCase: sl<LoadProgressUseCase>(),
      saveLocalProgressUseCase: sl<SaveLocalProgressUseCase>(),
      unlockNextLevelUseCase: sl<UnlockNextLevelUseCase>(),
    ),
  );

  // Leaderboard (Guest-First) — mock data source for now.
  sl.registerLazySingleton<ILeaderboardRepository>(
    MockLeaderboardRepository.new,
  );

  // Per-screen instances.
  sl
    ..registerFactory<LeaderboardCubit>(
      () => LeaderboardCubit(repository: sl<ILeaderboardRepository>()),
    )
    ..registerFactory<MenuBloc>(
      () => MenuBloc(getLevelListUseCase: sl<GetLevelListUseCase>()),
    )
    ..registerFactory<GameBloc>(
      () => GameBloc(
        loadLevelUseCase: sl<LoadLevelUseCase>(),
        startGameSessionUseCase: sl<StartGameSessionUseCase>(),
        evaluateGameStateUseCase: sl<EvaluateGameStateUseCase>(),
        triggerArrowExitUseCase: sl<TriggerArrowExitUseCase>(),
        undoMoveUseCase: sl<UndoMoveUseCase>(),
        calculateScoreUseCase: sl<CalculateScoreUseCase>(),
        unlockNextLevelUseCase: sl<UnlockNextLevelUseCase>(),
        collisionValidator: sl<CollisionValidator>(),
        audioService: sl<AudioService>(),
      ),
    );
}

/// Populates the levels box from the code-defined level catalogue on first
/// launch. Keyed by level id so [HiveLevelRepository] can `get(levelId)`.
void _seedLevels(Box<LevelModel> box) {
  if (box.isNotEmpty) return;
  final entries = <int, LevelModel>{
    for (final level in LevelDefinitions.campaignLevels) level.id: level,
  };
  box.putAll(entries);
}

/// Largest board dimension across all levels; used to size the single shared
/// collision topology so every level's exit trajectories resolve correctly.
///
/// Reads from the already-seeded [levelsBox] rather than regenerating
/// [LevelDefinitions.campaignLevels] on every launch — `_seedLevels` runs
/// before this, so the box is always populated by this point.
int _maxBoardSize(Box<LevelModel> levelsBox) {
  var maxDim = 1;
  for (final level in levelsBox.values) {
    maxDim = math.max(maxDim, math.max(level.boardSize.rows, level.boardSize.cols));
  }
  return maxDim;
}
