import 'package:arrowconmango_front/features/game/presentation/bloc/game_bloc.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_event.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_state.dart';
import 'package:arrowconmango_front/features/game/presentation/screens/game_screen.dart';
import 'package:arrowconmango_front/features/game/presentation/widgets/arrow_widget.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/game_test_setup.dart';

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
  });

  tearDown(() => bloc.close());

  Future<void> pumpGame(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<GameBloc>.value(
          value: bloc,
          child: const GameScreen(levelId: 1),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('should_render_hud_and_board_for_playing_state',
      (tester) async {
    // Act
    await pumpGame(tester);

    // Assert
    expect(find.text('Nivel 1 · Easy'), findsOneWidget);
    expect(find.text('2 flechas'), findsOneWidget);
    expect(find.text('0 toques'), findsOneWidget);
    expect(find.text('1:05'), findsOneWidget); // 65s
    expect(find.textContaining('Toca una flecha'), findsOneWidget);
    expect(find.byType(ArrowWidget), findsNWidgets(2));

    // Dispose the screen so its periodic timer is cancelled.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('should_dispatch_TriggerArrowExit_when_an_arrow_is_tapped',
      (tester) async {
    // Arrange
    await pumpGame(tester);

    // Act
    await tester.tap(find.byType(ArrowWidget).first);
    await tester.pump();

    // Assert
    verify(() => bloc.add(const TriggerArrowExit(arrowId: 'a1'))).called(1);

    await tester.pumpWidget(const SizedBox());
  });
}
