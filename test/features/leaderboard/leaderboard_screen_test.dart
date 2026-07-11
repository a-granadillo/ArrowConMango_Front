import 'package:arrowconmango_front/features/leaderboard/domain/leaderboard_entry.dart';
import 'package:arrowconmango_front/features/leaderboard/presentation/leaderboard_cubit.dart';
import 'package:arrowconmango_front/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:arrowconmango_front/features/leaderboard/presentation/leaderboard_state.dart';
import 'package:arrowconmango_front/features/player/domain/guest_player.dart';
import 'package:arrowconmango_front/features/player/presentation/player_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/player_test_setup.dart';

class MockLeaderboardCubit extends MockCubit<LeaderboardState>
    implements LeaderboardCubit {}

const _loaded = LeaderboardLoaded(
  entries: [
    LeaderboardEntry(rank: 1, uuid: 's1', displayName: 'MangoReina_88', mangos: 1580),
    LeaderboardEntry(
        rank: 2,
        uuid: 'me',
        displayName: 'MangoLoco_10',
        mangos: 640,
        isCurrentPlayer: true),
    LeaderboardEntry(rank: 3, uuid: 's2', displayName: 'PixelHero_09', mangos: 610),
  ],
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(const GuestPlayer(uuid: 'x', displayName: 'x'));
  });

  late MockLeaderboardCubit cubit;
  late PlayerCubit player;

  setUp(() {
    cubit = MockLeaderboardCubit();
    when(() => cubit.load(any())).thenAnswer((_) async {});
    whenListen(
      cubit,
      const Stream<LeaderboardState>.empty(),
      initialState: _loaded,
    );
    player = makePlayerCubit(name: 'MangoLoco_10');
  });

  tearDown(() => player.close());

  Future<void> pumpScreen(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<LeaderboardCubit>.value(value: cubit),
            BlocProvider<PlayerCubit>.value(value: player),
          ],
          child: const LeaderboardScreen(),
        ),
      ),
    );
  }

  testWidgets('should_render_ranking_and_highlight_current_player',
      (tester) async {
    // Act
    await pumpScreen(tester);
    await tester.pump();

    // Assert
    expect(find.text('Clasificación'), findsOneWidget);
    expect(find.text('Los mejores cosechadores'), findsOneWidget);
    expect(find.text('MangoReina_88'), findsOneWidget);
    expect(find.textContaining('MangoLoco_10 (Tú)'), findsOneWidget);
    expect(find.text('Vincular cuenta (Google / Apple)'), findsOneWidget);
    // The screen requested a load on entry.
    verify(() => cubit.load(any())).called(1);
  });

  testWidgets('should_show_snackbar_when_sign_in_tapped', (tester) async {
    // Arrange
    await pumpScreen(tester);
    await tester.pump();

    // Act
    await tester.tap(find.text('Vincular cuenta (Google / Apple)'));
    await tester.pump();

    // Assert
    expect(find.textContaining('próximamente'), findsOneWidget);

    // Let the snackbar auto-dismiss so no timer is left pending.
    await tester.pump(const Duration(seconds: 5));
  });
}
