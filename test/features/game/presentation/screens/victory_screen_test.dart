import 'dart:io';

import 'package:arrowconmango_front/core/app_info.dart';
import 'package:arrowconmango_front/core/audio/audio_service.dart';
import 'package:arrowconmango_front/core/database/hive_config.dart';
import 'package:arrowconmango_front/features/game/data/models/adapters/arrow_model_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/adapters/arrow_trajectory_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/adapters/board_size_model_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/adapters/board_state_model_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/adapters/level_model_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/adapters/node_model_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/adapters/trajectory_segment_adapter.dart';
import 'package:arrowconmango_front/features/game/data/models/board_size_model.dart';
import 'package:arrowconmango_front/features/game/data/models/board_state_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/entities/score.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_state.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/progress_bloc.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/progress_event.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/progress_state.dart';
import 'package:arrowconmango_front/features/game/presentation/screens/victory_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fakes/fake_audio_service.dart';

class MockProgressBloc extends MockBloc<ProgressEvent, ProgressState>
    implements ProgressBloc {}

void main() {
  late Directory levelsDir;
  late Box<LevelModel> levelsBox;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    // AppInfo.totalLevels reads the already-open levels_v2 box (see
    // core/app_info.dart) rather than regenerating the level catalogue, so
    // this pure widget test backs it with a real temp-dir Hive box instead
    // of pulling in HiveConfig.initialise()'s platform-channel dependencies.
    levelsDir = Directory.systemTemp.createTempSync('acm_victory_test');
    Hive.init(levelsDir.path);
    Hive.registerAdapter(NodeModelAdapter());
    Hive.registerAdapter(ArrowModelAdapter());
    Hive.registerAdapter(BoardStateModelAdapter());
    Hive.registerAdapter(LevelModelAdapter());
    Hive.registerAdapter(TrajectorySegmentAdapter());
    Hive.registerAdapter(ArrowTrajectoryAdapter());
    Hive.registerAdapter(BoardSizeModelAdapter());
    levelsBox = await Hive.openBox<LevelModel>(HiveConfig.levelsBoxName);
    await levelsBox.putAll({
      for (var i = 1; i <= 3; i++)
        i: LevelModel(
          id: i,
          name: 'Test Level $i',
          difficulty: 'Easy',
          boardSize: const BoardSizeModel(rows: 3, cols: 3),
          boardState: const BoardStateModel(arrows: []),
        ),
    });
  });

  tearDownAll(() async {
    await levelsBox.close();
    try {
      levelsDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  late MockProgressBloc progressBloc;

  setUp(() {
    progressBloc = MockProgressBloc();
    whenListen(
      progressBloc,
      const Stream<ProgressState>.empty(),
      initialState: const ProgressLoaded(
        progress: AppProgress(unlockedLevels: [1]),
      ),
    );
  });

  tearDown(() => progressBloc.close());

  Future<void> pumpVictory(WidgetTester tester, GameVictory result) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RepositoryProvider<AudioService>.value(
          value: FakeAudioService(),
          child: BlocProvider<ProgressBloc>.value(
            value: progressBloc,
            child: VictoryScreen(result: result),
          ),
        ),
      ),
    );
    await tester.pump(); // run the post-frame callback
  }

  testWidgets('should_show_score_and_persist_unlock', (tester) async {
    // Arrange
    const result = GameVictory(
      levelId: 1,
      score: Score(totalPoints: 850),
      moveCount: 12,
      elapsedSeconds: 45,
    );

    // Act
    await pumpVictory(tester, result);

    // Assert
    expect(find.text('¡ENHORABUENA!'), findsOneWidget);
    expect(find.text('850'), findsOneWidget);
    expect(find.text('Mangos'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('0:45'), findsOneWidget);
    expect(find.text('Siguiente nivel'), findsOneWidget);
    expect(find.text('Menú'), findsOneWidget);
    verify(
      () => progressBloc.add(const ProgressLevelCompleted(currentLevelId: 1)),
    ).called(1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('should_hide_next_level_on_last_level', (tester) async {
    // Arrange
    final result = GameVictory(
      levelId: AppInfo.totalLevels,
      score: const Score(totalPoints: 100),
      moveCount: 5,
      elapsedSeconds: 30,
    );

    // Act
    await pumpVictory(tester, result);

    // Assert
    expect(find.text('Siguiente nivel'), findsNothing);
    expect(find.text('Menú'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
