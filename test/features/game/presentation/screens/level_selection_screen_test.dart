import 'package:arrowconmango_front/features/game/application/use_cases/get_level_list_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/menu_bloc.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/menu_event.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/menu_state.dart';
import 'package:arrowconmango_front/features/game/presentation/screens/level_selection_screen.dart';
import 'package:arrowconmango_front/features/game/presentation/widgets/level_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../helpers/fakes/fake_level_repository.dart';
import '../../../../helpers/fakes/fake_progress_repository.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late FakeLevelRepository levelRepo;
  late FakeProgressRepository progressRepo;
  late MenuBloc menuBloc;

  setUp(() {
    levelRepo = FakeLevelRepository()..countResult = const Success<int>(15);
    progressRepo = FakeProgressRepository()
      ..loadResult = const Success<AppProgress>(
        AppProgress(unlockedLevels: [1, 2, 3]),
      );
    menuBloc = MenuBloc(
      getLevelListUseCase: GetLevelListUseCase(levelRepo, progressRepo),
    );
  });

  tearDown(() => menuBloc.close());

  Future<void> pumpLevels(WidgetTester tester) async {
    // Drive the bloc to MenuLoaded (real async) BEFORE building, so the loading
    // spinner (which animates forever) never blocks the pump. `runAsync` lets
    // the real event loop process the bloc under the widget-test fake clock.
    await tester.runAsync(() async {
      menuBloc.add(const MenuLevelsRequested());
      await menuBloc.stream.firstWhere((s) => s is MenuLoaded);
    });
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<MenuBloc>.value(
          value: menuBloc,
          child: const LevelSelectionScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('should_render_all_levels_with_unlocked_count', (tester) async {
    // Act
    await pumpLevels(tester);

    // Assert. The subtitle proves the 15-total / 3-unlocked split; the grid is
    // lazy so we verify the unlock mapping via specific visible cards instead
    // of exact counts.
    expect(find.text('Seleccionar Nivel'), findsOneWidget);
    expect(find.text('3 de 15 disponibles'), findsOneWidget);
    expect(find.byType(LevelCard), findsWidgets);
    // Unlocked levels (1-3) render their number.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    // Locked levels render as "Nivel N" (not a bare number).
    expect(find.text('Nivel 4'), findsOneWidget);
    expect(find.text('4'), findsNothing);
  });
}
