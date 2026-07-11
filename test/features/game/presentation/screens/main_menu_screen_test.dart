import 'package:arrowconmango_front/features/game/presentation/screens/main_menu_screen.dart';
import 'package:arrowconmango_front/features/player/presentation/player_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../helpers/player_test_setup.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpMenu(WidgetTester tester, PlayerCubit cubit) {
    return tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<PlayerCubit>.value(
          value: cubit,
          child: const MainMenuScreen(),
        ),
      ),
    );
  }

  testWidgets('should_show_title_greeting_and_actions', (tester) async {
    // Arrange
    final cubit = makePlayerCubit(name: 'MangoLoco_10');
    addTearDown(cubit.close);

    // Act
    await pumpMenu(tester, cubit);

    // Assert
    expect(find.text('ARROW CON MANGO'), findsOneWidget);
    expect(find.text('¡Hola, MangoLoco_10!'), findsOneWidget);
    expect(find.text('JUGAR'), findsOneWidget);
    expect(find.text('Ranking'), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);
  });
}
