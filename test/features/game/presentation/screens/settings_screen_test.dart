import 'package:arrowconmango_front/features/game/presentation/screens/settings_screen.dart';
import 'package:arrowconmango_front/features/player/presentation/player_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../helpers/player_test_setup.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpSettings(WidgetTester tester, PlayerCubit cubit) {
    return tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<PlayerCubit>.value(
          value: cubit,
          child: const SettingsScreen(),
        ),
      ),
    );
  }

  testWidgets('should_render_settings_options', (tester) async {
    // Arrange
    final cubit = makePlayerCubit(name: 'MangoLoco_10');
    addTearDown(cubit.close);

    // Act
    await pumpSettings(tester, cubit);

    // Assert
    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Nombre de jugador'), findsOneWidget);
    expect(find.text('MangoLoco_10'), findsOneWidget);
    expect(find.text('Sonido'), findsOneWidget);
    expect(find.text('Idioma'), findsOneWidget);
  });

  testWidgets('should_update_name_when_edited_and_saved', (tester) async {
    // Arrange
    final cubit = makePlayerCubit(name: 'MangoLoco_10');
    addTearDown(cubit.close);
    await pumpSettings(tester, cubit);

    // Act: open the editor, type a new name, save.
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Abraham');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    // Assert
    expect(cubit.state.displayName, 'Abraham');
    expect(find.text('Abraham'), findsOneWidget);
  });
}
