import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/creative/presentation/screens/community_levels_screen.dart';
import '../../features/creative/presentation/screens/creative_hub_screen.dart';
import '../../features/creative/presentation/screens/hex_community_levels_screen.dart';
import '../../features/creative/presentation/screens/hex_level_editor_screen.dart';
import '../../features/creative/presentation/screens/hex_level_ranking_screen.dart';
import '../../features/creative/presentation/screens/hex_my_levels_screen.dart';
import '../../features/creative/presentation/screens/level_editor_screen.dart';
import '../../features/creative/presentation/screens/level_ranking_screen.dart';
import '../../features/creative/presentation/screens/my_levels_screen.dart';
import '../../features/game/domain/entities/creative_level.dart';
import '../../features/game/domain/entities/hex_level.dart';
import '../../features/game/presentation/bloc/game_bloc.dart';
import '../../features/game/presentation/bloc/game_state.dart';
import '../../features/game/presentation/bloc/menu_bloc.dart';
import '../../features/game/presentation/bloc/menu_event.dart';
import '../../features/game/presentation/bloc/cube3d/cube3d_game_cubit.dart';
import '../../features/game/presentation/bloc/hex/hex_game_cubit.dart';
import '../../features/game/presentation/screens/defeat_screen.dart';
import '../../features/game/presentation/screens/game_3d_screen.dart';
import '../../features/game/presentation/screens/game_hex_screen.dart';
import '../../features/game/presentation/screens/game_screen.dart';
import '../../features/game/presentation/screens/level_selection_screen.dart';
import '../../features/game/presentation/screens/main_menu_screen.dart';
import '../../features/game/presentation/screens/play_hub_screen.dart';
import '../../features/game/presentation/screens/victory_screen.dart';
import '../../features/game/presentation/screens/settings_screen.dart';
import '../../features/game/presentation/screens/splash_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_cubit.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/player/presentation/bloc/auth_cubit.dart';
import '../../features/player/presentation/screens/auth_gate_screen.dart';
import '../di/service_locator.dart';
import '../widgets/mango_background.dart';
import 'app_routes.dart';

/// Builds the application's [GoRouter].
///
/// NOTE: `/game`, `/victory` and `/defeat` currently render placeholders.
/// They are replaced by the real screens in issues #5 (Game) and #12 (Results).
GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>(),
          child: const AuthGateScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.menu,
        builder: (context, state) => const MainMenuScreen(),
      ),
      GoRoute(
        path: AppRoutes.playHub,
        builder: (context, state) => const PlayHubScreen(),
      ),
      GoRoute(
        path: AppRoutes.levels,
        builder: (context, state) => BlocProvider<MenuBloc>(
          create: (_) => sl<MenuBloc>()..add(const MenuLevelsRequested()),
          child: const LevelSelectionScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>(),
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.game3d,
        builder: (context, state) => BlocProvider<Cube3DGameCubit>(
          create: (_) => sl<Cube3DGameCubit>(),
          child: const Game3DScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.gameHex,
        builder: (context, state) => BlocProvider<HexGameCubit>(
          create: (_) => sl<HexGameCubit>(),
          child: const GameHexScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.ranking,
        builder: (context, state) => BlocProvider<LeaderboardCubit>(
          create: (_) => sl<LeaderboardCubit>(),
          child: const LeaderboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.game,
        builder: (context, state) {
          final levelId =
              int.tryParse(state.pathParameters['levelId'] ?? '') ?? 1;
          return BlocProvider<GameBloc>(
            create: (_) => sl<GameBloc>(),
            child: GameScreen(levelId: levelId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.victory,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is GameVictory) {
            return VictoryScreen(result: extra);
          }
          if (extra is Map<String, dynamic>) {
            return VictoryScreen(
              result: extra['result'] as GameVictory,
              bloc: extra['bloc'] as GameBloc?,
              communityLevelId: extra['communityLevelId'] as String?,
              onEditorTestSolved:
                  extra['onEditorTestSolved'] as VoidCallback?,
            );
          }
          return const _Placeholder(
            title: 'Sin datos',
            message: 'No hay un resultado que mostrar.',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.defeat,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is GameDefeat) {
            return DefeatScreen(result: extra);
          }
          if (extra is Map<String, dynamic>) {
            return DefeatScreen(
              result: extra['result'] as GameDefeat,
              bloc: extra['bloc'] as GameBloc?,
              communityLevelId: extra['communityLevelId'] as String?,
              isEditorTestPlay: extra['isEditorTestPlay'] as bool? ?? false,
            );
          }
          return const _Placeholder(
            title: 'Sin datos',
            message: 'No hay un resultado que mostrar.',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.creativeHub,
        builder: (context, state) => const CreativeHubScreen(),
      ),
      GoRoute(
        path: AppRoutes.creativeEditor,
        builder: (context, state) =>
            LevelEditorScreen(existing: state.extra as CreativeLevel?),
      ),
      GoRoute(
        path: AppRoutes.creativeMine,
        builder: (context, state) => const MyLevelsScreen(),
      ),
      GoRoute(
        path: AppRoutes.creativeCommunity,
        builder: (context, state) => const CommunityLevelsScreen(),
      ),
      GoRoute(
        path: AppRoutes.creativeRanking,
        builder: (context, state) =>
            LevelRankingScreen(level: state.extra as CreativeLevel),
      ),
      GoRoute(
        path: AppRoutes.creativeEditorHex,
        builder: (context, state) =>
            HexLevelEditorScreen(existing: state.extra as HexLevel?),
      ),
      GoRoute(
        path: AppRoutes.creativeMineHex,
        builder: (context, state) => const HexMyLevelsScreen(),
      ),
      GoRoute(
        path: AppRoutes.creativeCommunityHex,
        builder: (context, state) => const HexCommunityLevelsScreen(),
      ),
      GoRoute(
        path: AppRoutes.creativeRankingHex,
        builder: (context, state) =>
            HexLevelRankingScreen(level: state.extra as HexLevel),
      ),
    ],
  );
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return MangoBackground(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.menu),
              child: const Text('Menú'),
            ),
          ],
        ),
      ),
    );
  }
}
