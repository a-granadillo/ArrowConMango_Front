import 'package:arrowconmango_front/features/game/presentation/bloc/game_bloc.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_event.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_state.dart';
import 'package:arrowconmango_front/features/game/presentation/screens/game_screen.dart';
import 'package:arrowconmango_front/features/game/presentation/widgets/board_grid_widget.dart';
import 'package:arrowconmango_front/features/game/presentation/widgets/painting/arrows_layer_painter.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/game_test_setup.dart';
import '../../../../helpers/pump_localized_app.dart';

class MockGameBloc extends MockBloc<GameEvent, GameState> implements GameBloc {}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late MockGameBloc bloc;

  setUp(() {
    bloc = MockGameBloc();
    whenListen(
      bloc,
      const Stream<GameState>.empty(),
      initialState: makePlaying(elapsedSeconds: 65),
    );
    when(() => bloc.arrowCollisions)
        .thenAnswer((_) => const Stream.empty());
  });

  tearDown(() => bloc.close());

  Future<void> pumpGame(WidgetTester tester) async {
    await pumpLocalizedApp(
      tester,
      BlocProvider<GameBloc>.value(
        value: bloc,
        child: const GameScreen(levelId: 1),
      ),
    );
    await tester.pump();
  }

  testWidgets('should_render_hud_and_board_for_playing_state',
      (tester) async {
    // Act
    await pumpGame(tester);

    // Assert — HUD: title + "Nivel N · dificultad" subtitle and stat chips.
    expect(find.text('Nivel 1'), findsOneWidget); // title fallback (no name)
    expect(find.text('Nivel 1 · Fácil'), findsOneWidget); // subtitle in Spanish
    expect(find.text('2'), findsOneWidget); // arrows remaining
    expect(find.text('flechas'), findsOneWidget);
    expect(find.text('0'), findsOneWidget); // taps
    expect(find.text('toques'), findsOneWidget);
    expect(find.text('1:05'), findsOneWidget); // 65s
    expect(find.textContaining('Toca una flecha'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is ArrowsLayerPainter,
      ),
      findsOneWidget,
    );

    // Dispose the screen so its periodic timer is cancelled.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('should_dispatch_TriggerArrowExit_when_an_arrow_cell_is_tapped',
      (tester) async {
    // Arrange
    await pumpGame(tester);

    // Act: tap cell (0,0), occupied by arrow a1 (rows/cols = 4 in makePlaying).
    final gd = find.descendant(
      of: find.byType(BoardGridWidget),
      matching: find.byType(GestureDetector),
    );
    final topLeft = tester.getTopLeft(gd);
    final size = tester.getSize(gd);
    final cell = size.width / 4;
    await tester.tapAt(topLeft + Offset(0.5 * cell, 0.5 * cell));
    await tester.pump();

    // Assert
    verify(() => bloc.add(const TriggerArrowExit(arrowId: 'a1'))).called(1);

    await tester.pumpWidget(const SizedBox());
  });
}
