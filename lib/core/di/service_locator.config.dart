// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:hive/hive.dart' as _i979;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/game/application/use_cases/calculate_score_use_case.dart'
    as _i513;
import '../../features/game/application/use_cases/evaluate_game_state_use_case.dart'
    as _i749;
import '../../features/game/application/use_cases/get_level_definition_use_case.dart'
    as _i853;
import '../../features/game/application/use_cases/get_level_list_use_case.dart'
    as _i1040;
import '../../features/game/application/use_cases/load_level_use_case.dart'
    as _i617;
import '../../features/game/application/use_cases/load_progress_use_case.dart'
    as _i739;
import '../../features/game/application/use_cases/save_local_progress_use_case.dart'
    as _i16;
import '../../features/game/application/use_cases/start_game_session_use_case.dart'
    as _i469;
import '../../features/game/application/use_cases/submit_score_use_case.dart'
    as _i908;
import '../../features/game/application/use_cases/trigger_arrow_exit_use_case.dart'
    as _i47;
import '../../features/game/application/use_cases/undo_move_use_case.dart'
    as _i457;
import '../../features/game/application/use_cases/unlock_next_level_use_case.dart'
    as _i1015;
import '../../features/game/data/datasources/remote_leaderboard_data_source.dart'
    as _i924;
import '../../features/game/data/datasources/remote_progress_data_source.dart'
    as _i1063;
import '../../features/game/data/models/app_progress_model.dart' as _i358;
import '../../features/game/data/models/level_model.dart' as _i50;
import '../../features/game/data/models/mappers/app_progress_mapper.dart'
    as _i557;
import '../../features/game/data/models/mappers/arrow_mapper.dart' as _i330;
import '../../features/game/data/models/mappers/board_state_mapper.dart'
    as _i1070;
import '../../features/game/data/models/mappers/level_mapper.dart' as _i61;
import '../../features/game/data/repositories/hive_level_repository.dart'
    as _i821;
import '../../features/game/data/repositories/hive_progress_repository.dart'
    as _i329;
import '../../features/game/data/repositories/synced_progress_repository.dart'
    as _i1036;
import '../../features/game/domain/entities/scoring_strategy.dart' as _i440;
import '../../features/game/domain/repositories/i_level_repository.dart'
    as _i76;
import '../../features/game/domain/repositories/i_progress_repository.dart'
    as _i10;
import '../../features/game/domain/services/collision_validator.dart' as _i775;
import '../../features/game/presentation/bloc/menu_bloc.dart' as _i49;
import '../../features/game/presentation/bloc/progress_bloc.dart' as _i424;
import '../../features/leaderboard/data/api_leaderboard_repository.dart'
    as _i330;
import '../../features/leaderboard/domain/i_leaderboard_repository.dart'
    as _i651;
import '../../features/leaderboard/presentation/leaderboard_cubit.dart'
    as _i143;
import '../../features/player/data/remote_player_data_source.dart' as _i803;
import '../audio/audio_service.dart' as _i910;
import '../audio/audio_service_impl.dart' as _i478;
import '../audio/audio_settings_cubit.dart' as _i151;
import '../audio/audio_settings_local_data_source.dart' as _i598;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i979.Box<_i50.LevelModel>>(
      () => registerModule.levelsBox,
    );
    gh.lazySingleton<_i979.Box<_i358.AppProgressModel>>(
      () => registerModule.progressBox,
    );
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
    gh.lazySingleton<_i440.ScoringStrategy>(
      () => registerModule.scoringStrategy,
    );
    gh.lazySingleton<_i775.CollisionValidator>(
      () => registerModule.collisionValidator,
    );
    gh.lazySingleton<_i469.StartGameSessionUseCase>(
      () => const _i469.StartGameSessionUseCase(),
    );
    gh.lazySingleton<_i457.UndoMoveUseCase>(
      () => const _i457.UndoMoveUseCase(),
    );
    gh.lazySingleton<_i557.AppProgressMapper>(
      () => const _i557.AppProgressMapper(),
    );
    gh.lazySingleton<_i330.ArrowMapper>(() => const _i330.ArrowMapper());
    gh.lazySingleton<_i775.CollisionValidator>(
      () => registerModule.cube3dCollisionValidator,
      instanceName: 'cube3d',
    );
    gh.lazySingleton<_i1070.BoardStateMapper>(
      () => _i1070.BoardStateMapper(gh<_i330.ArrowMapper>()),
    );
    gh.lazySingleton<_i924.RemoteLeaderboardDataSource>(
      () => _i924.RemoteLeaderboardDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i1063.RemoteProgressDataSource>(
      () => _i1063.RemoteProgressDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i803.RemotePlayerDataSource>(
      () => _i803.RemotePlayerDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i979.Box<dynamic>>(
      () => registerModule.playerBox,
      instanceName: 'playerBox',
    );
    gh.lazySingleton<_i979.Box<dynamic>>(
      () => registerModule.audioBox,
      instanceName: 'audioBox',
    );
    gh.lazySingleton<_i61.LevelMapper>(
      () => _i61.LevelMapper(gh<_i1070.BoardStateMapper>()),
    );
    gh.lazySingleton<_i513.CalculateScoreUseCase>(
      () => _i513.CalculateScoreUseCase(gh<_i440.ScoringStrategy>()),
    );
    gh.lazySingleton<_i749.EvaluateGameStateUseCase>(
      () => _i749.EvaluateGameStateUseCase(gh<_i440.ScoringStrategy>()),
    );
    gh.lazySingleton<_i651.ILeaderboardRepository>(
      () => _i330.ApiLeaderboardRepository(
        gh<_i924.RemoteLeaderboardDataSource>(),
      ),
    );
    gh.lazySingleton<_i598.AudioSettingsLocalDataSource>(
      () => _i598.AudioSettingsLocalDataSource(
        box: gh<_i979.Box<dynamic>>(instanceName: 'audioBox'),
      ),
    );
    gh.lazySingleton<_i908.SubmitScoreUseCase>(
      () => _i908.SubmitScoreUseCase(gh<_i924.RemoteLeaderboardDataSource>()),
    );
    gh.lazySingleton<_i329.HiveProgressRepository>(
      () => _i329.HiveProgressRepository(
        gh<_i979.Box<_i358.AppProgressModel>>(),
        gh<_i557.AppProgressMapper>(),
      ),
    );
    gh.lazySingleton<_i47.TriggerArrowExitUseCase>(
      () => _i47.TriggerArrowExitUseCase(gh<_i775.CollisionValidator>()),
    );
    gh.lazySingleton<_i47.TriggerArrowExitUseCase>(
      () => registerModule.cube3dTriggerArrowExitUseCase(
        gh<_i775.CollisionValidator>(instanceName: 'cube3d'),
      ),
      instanceName: 'cube3d',
    );
    gh.lazySingleton<_i910.AudioService>(
      () => _i478.AudioServiceImpl(
        settings: gh<_i598.AudioSettingsLocalDataSource>(),
      ),
      dispose: _i478.disposeAudioService,
    );
    gh.lazySingleton<_i10.IProgressRepository>(
      () => _i1036.SyncedProgressRepository(
        local: gh<_i329.HiveProgressRepository>(),
        remote: gh<_i1063.RemoteProgressDataSource>(),
        mapper: gh<_i557.AppProgressMapper>(),
        connectivity: gh<_i895.Connectivity>(),
        scoringStrategy: gh<_i440.ScoringStrategy>(),
        pendingFlagBox: gh<_i979.Box<dynamic>>(instanceName: 'playerBox'),
      ),
    );
    gh.factory<_i143.LeaderboardCubit>(
      () => _i143.LeaderboardCubit(
        repository: gh<_i651.ILeaderboardRepository>(),
      ),
    );
    gh.lazySingleton<_i76.ILevelRepository>(
      () => _i821.HiveLevelRepository(
        gh<_i979.Box<_i50.LevelModel>>(),
        gh<_i61.LevelMapper>(),
      ),
    );
    gh.lazySingleton<_i151.AudioSettingsCubit>(
      () => _i151.AudioSettingsCubit(service: gh<_i910.AudioService>()),
      dispose: _i151.disposeAudioSettingsCubit,
    );
    gh.lazySingleton<_i739.LoadProgressUseCase>(
      () => _i739.LoadProgressUseCase(gh<_i10.IProgressRepository>()),
    );
    gh.lazySingleton<_i16.SaveLocalProgressUseCase>(
      () => _i16.SaveLocalProgressUseCase(gh<_i10.IProgressRepository>()),
    );
    gh.lazySingleton<_i1040.GetLevelListUseCase>(
      () => _i1040.GetLevelListUseCase(
        gh<_i76.ILevelRepository>(),
        gh<_i10.IProgressRepository>(),
        gh<_i440.ScoringStrategy>(),
      ),
    );
    gh.factory<_i49.MenuBloc>(
      () =>
          _i49.MenuBloc(getLevelListUseCase: gh<_i1040.GetLevelListUseCase>()),
    );
    gh.lazySingleton<_i1015.UnlockNextLevelUseCase>(
      () => _i1015.UnlockNextLevelUseCase(
        gh<_i10.IProgressRepository>(),
        gh<_i76.ILevelRepository>(),
      ),
    );
    gh.lazySingleton<_i853.GetLevelDefinitionUseCase>(
      () => _i853.GetLevelDefinitionUseCase(gh<_i76.ILevelRepository>()),
    );
    gh.lazySingleton<_i617.LoadLevelUseCase>(
      () => _i617.LoadLevelUseCase(
        gh<_i76.ILevelRepository>(),
        gh<_i61.LevelMapper>(),
      ),
    );
    gh.lazySingleton<_i424.ProgressBloc>(
      () => _i424.ProgressBloc(
        loadProgressUseCase: gh<_i739.LoadProgressUseCase>(),
        saveLocalProgressUseCase: gh<_i16.SaveLocalProgressUseCase>(),
        unlockNextLevelUseCase: gh<_i1015.UnlockNextLevelUseCase>(),
        submitScoreUseCase: gh<_i908.SubmitScoreUseCase>(),
        scoringStrategy: gh<_i440.ScoringStrategy>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
