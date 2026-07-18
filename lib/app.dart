import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/audio/audio_service.dart';
import 'core/audio/audio_settings_cubit.dart';
import 'core/di/service_locator.dart';
import 'core/i18n/locale_cubit.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/game/presentation/bloc/progress_bloc.dart';
import 'features/game/presentation/bloc/progress_event.dart';
import 'features/player/presentation/player_cubit.dart';
import 'l10n/app_localizations.dart';

/// Root application widget.
///
/// Provides the app-wide BLoCs (global progress + guest player) and wires the
/// themed [MaterialApp.router].
class ArrowConMangoApp extends StatefulWidget {
  const ArrowConMangoApp({super.key});

  @override
  State<ArrowConMangoApp> createState() => _ArrowConMangoAppState();
}

class _ArrowConMangoAppState extends State<ArrowConMangoApp>
    with WidgetsBindingObserver {
  late final _router = buildAppRouter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        sl<AudioService>().pause();
      case AppLifecycleState.resumed:
        sl<AudioService>().resume();
      case AppLifecycleState.detached:
        sl<AudioService>().dispose();
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AudioService>.value(
      value: sl<AudioService>(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
          BlocProvider<ProgressBloc>.value(
            value: sl<ProgressBloc>()..add(const ProgressLoadStarted()),
          ),
          BlocProvider<PlayerCubit>.value(value: sl<PlayerCubit>()),
          BlocProvider<AudioSettingsCubit>.value(
            value: sl<AudioSettingsCubit>(),
          ),
        ],
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) => MaterialApp.router(
            title: 'Arrow con Mango',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: _router,
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es'),
              Locale('en'),
            ],
          ),
        ),
      ),
    );
  }
}
