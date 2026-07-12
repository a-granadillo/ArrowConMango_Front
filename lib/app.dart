import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/audio/audio_settings_cubit.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/game/presentation/bloc/progress_bloc.dart';
import 'features/game/presentation/bloc/progress_event.dart';
import 'features/player/presentation/player_cubit.dart';

/// Root application widget.
///
/// Provides the app-wide BLoCs (global progress + guest player) and wires the
/// themed [MaterialApp.router].
class ArrowConMangoApp extends StatefulWidget {
  const ArrowConMangoApp({super.key});

  @override
  State<ArrowConMangoApp> createState() => _ArrowConMangoAppState();
}

class _ArrowConMangoAppState extends State<ArrowConMangoApp> {
  late final _router = buildAppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProgressBloc>.value(
          value: sl<ProgressBloc>()..add(const ProgressLoadStarted()),
        ),
        BlocProvider<PlayerCubit>.value(value: sl<PlayerCubit>()),
        BlocProvider<AudioSettingsCubit>.value(value: sl<AudioSettingsCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Arrow con Mango',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
