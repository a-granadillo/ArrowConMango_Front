import 'package:arrowconmango_front/features/game/application/dtos/level_summary.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/get_level_list_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/leaderboard/domain/leaderboard_entry.dart';
import 'package:arrowconmango_front/features/leaderboard/presentation/leaderboard_cubit.dart';
import 'package:arrowconmango_front/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:arrowconmango_front/features/leaderboard/presentation/leaderboard_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_localized_app.dart';

class MockLeaderboardCubit extends MockCubit<LeaderboardState>
    implements LeaderboardCubit {}

class MockGetLevelListUseCase extends Mock implements GetLevelListUseCase {}

// Ranks 1-3 land in the podium; the current player at rank 4 lands in the
// scrollable list, where the "(Tú)" highlight is applied.
const _byLevelLoaded = LeaderboardLoaded(
  tab: LeaderboardTab.byLevel,
  selectedLevelId: '1',
  page: LeaderboardPage(
    top: [
      LeaderboardEntry(
        rank: 1,
        uuid: 's1',
        displayName: 'MangoReina_88',
        mangos: 950,
        secondaryValue: 5,
        metric: LeaderboardMetric.moves,
        colorValue: 0xFFF4843D,
      ),
      LeaderboardEntry(
        rank: 2,
        uuid: 's2',
        displayName: 'ArrowKing_07',
        mangos: 900,
        secondaryValue: 6,
        metric: LeaderboardMetric.moves,
        colorValue: 0xFF4CAF50,
      ),
      LeaderboardEntry(
        rank: 3,
        uuid: 's3',
        displayName: 'PixelHero_09',
        mangos: 610,
        secondaryValue: 7,
        metric: LeaderboardMetric.moves,
        colorValue: 0xFF9B6BC7,
      ),
      LeaderboardEntry(
        rank: 4,
        uuid: 'me',
        displayName: 'MangoLoco_10',
        mangos: 400,
        secondaryValue: 9,
        metric: LeaderboardMetric.moves,
        colorValue: 0xFFF9C74F,
        isCurrentPlayer: true,
      ),
    ],
    me: LeaderboardEntry(
      rank: 4,
      uuid: 'me',
      displayName: 'MangoLoco_10',
      mangos: 400,
      secondaryValue: 9,
      metric: LeaderboardMetric.moves,
      colorValue: 0xFFF9C74F,
      isCurrentPlayer: true,
    ),
  ),
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late MockLeaderboardCubit cubit;
  late MockGetLevelListUseCase getLevelListUseCase;

  setUp(() {
    cubit = MockLeaderboardCubit();
    getLevelListUseCase = MockGetLevelListUseCase();
    when(() => cubit.loadByLevel(any(), refresh: any(named: 'refresh')))
        .thenAnswer((_) async {});
    when(() => cubit.loadSurvival(refresh: any(named: 'refresh')))
        .thenAnswer((_) async {});
    when(() => getLevelListUseCase()).thenAnswer(
      (_) async => const Success<List<LevelSummary>>([
        LevelSummary(levelId: 1, isUnlocked: true),
      ]),
    );
    whenListen(
      cubit,
      const Stream<LeaderboardState>.empty(),
      initialState: _byLevelLoaded,
    );
  });

  Future<void> pumpScreen(WidgetTester tester) {
    return pumpLocalizedApp(
      tester,
      BlocProvider<LeaderboardCubit>.value(
        value: cubit,
        child: LeaderboardScreen(getLevelListUseCase: getLevelListUseCase),
      ),
    );
  }

  testWidgets(
    'should_render_podium_pinned_position_and_highlight_current_player',
    (tester) async {
      // Act
      await pumpScreen(tester);
      await tester.pump();
      await tester.pump();

      // Assert
      expect(find.text('Clasificación'), findsOneWidget);
      expect(find.text('Los mejores cosechadores'), findsOneWidget);
      // Top 3 render in the podium.
      expect(find.text('MangoReina_88'), findsOneWidget);
      expect(find.text('ArrowKing_07'), findsOneWidget);
      expect(find.text('PixelHero_09'), findsOneWidget);
      // Rank 4 (the current player) appears both in the list and pinned at
      // the bottom, highlighted with "(Tú)" in both places.
      expect(find.textContaining('MangoLoco_10 (Tú)'), findsWidgets);
      expect(find.text('Tu posición'), findsOneWidget);
      // The screen requested the by-level ranking for the default level.
      verify(() => cubit.loadByLevel('1')).called(1);
    },
  );

  testWidgets(
    'should_switch_to_the_survival_tab_and_load_it',
    (tester) async {
      // Arrange
      await pumpScreen(tester);
      await tester.pump();
      await tester.pump();

      // Act
      await tester.tap(find.text('Supervivencia'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => cubit.loadSurvival()).called(1);
    },
  );
}
