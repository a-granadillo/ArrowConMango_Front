import 'package:arrowconmango_front/core/audio/audio_service.dart';
import 'package:arrowconmango_front/core/audio/audio_settings_cubit.dart';
import 'package:arrowconmango_front/core/audio/audio_settings_state.dart';
import 'package:arrowconmango_front/core/i18n/locale_cubit.dart';
import 'package:arrowconmango_front/features/game/presentation/screens/settings_screen.dart';
import 'package:arrowconmango_front/features/player/presentation/player_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../helpers/fakes/fake_audio_service.dart';
import '../../../../helpers/player_test_setup.dart';
import '../../../../helpers/pump_localized_app.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpSettings(
    WidgetTester tester,
    PlayerCubit playerCubit,
    AudioSettingsCubit audioCubit,
    LocaleCubit localeCubit,
  ) {
    return pumpLocalizedApp(
      tester,
      RepositoryProvider<AudioService>.value(
        value: FakeAudioService(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<PlayerCubit>.value(value: playerCubit),
            BlocProvider<AudioSettingsCubit>.value(value: audioCubit),
            BlocProvider<LocaleCubit>.value(value: localeCubit),
          ],
          child: const SettingsScreen(),
        ),
      ),
    );
  }

  testWidgets('should_render_settings_options', (tester) async {
    // Arrange
    final playerCubit = makePlayerCubit(name: 'MangoLoco_10');
    final audioCubit = AudioSettingsCubit(service: FakeAudioService());
    final localeCubit = LocaleCubit();
    addTearDown(playerCubit.close);
    addTearDown(audioCubit.close);
    addTearDown(localeCubit.close);

    // Act
    await pumpSettings(tester, playerCubit, audioCubit, localeCubit);

    // Assert
    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Nombre de jugador'), findsOneWidget);
    expect(find.text('MangoLoco_10'), findsOneWidget);
    expect(find.text('Sonido'), findsOneWidget);
    expect(find.text('Idioma'), findsOneWidget);
  });

  testWidgets('should_update_name_when_edited_and_saved', (tester) async {
    // Arrange
    final playerCubit = makePlayerCubit(name: 'MangoLoco_10');
    final audioCubit = AudioSettingsCubit(service: FakeAudioService());
    final localeCubit = LocaleCubit();
    addTearDown(playerCubit.close);
    addTearDown(audioCubit.close);
    addTearDown(localeCubit.close);
    await pumpSettings(tester, playerCubit, audioCubit, localeCubit);

    // Act: open the editor, type a new name, save.
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Abraham');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    // Assert
    expect(playerCubit.state.displayName, 'Abraham');
    expect(find.text('Abraham'), findsOneWidget);
  });

  testWidgets(
    'when audio switch is tapped, it should call toggleMute on AudioSettingsCubit',
    (tester) async {
      // Arrange
      final playerCubit = makePlayerCubit(name: 'MangoLoco_10');
      final fakeAudioService = FakeAudioService();
      final audioCubit = AudioSettingsCubit(service: fakeAudioService);
      final localeCubit = LocaleCubit();
      addTearDown(playerCubit.close);
      addTearDown(audioCubit.close);
      addTearDown(localeCubit.close);
      await pumpSettings(tester, playerCubit, audioCubit, localeCubit);

      // Act
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Assert
      expect(fakeAudioService.muteCalls, 1);
      expect(audioCubit.state, const AudioSettingsState(isMuted: true));
    },
  );
}
