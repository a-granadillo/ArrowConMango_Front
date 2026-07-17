import 'dart:io';

import 'package:arrowconmango_front/core/audio/audio_service.dart';
import 'package:arrowconmango_front/core/audio/audio_settings_cubit.dart';
import 'package:arrowconmango_front/core/audio/audio_settings_state.dart';
import 'package:arrowconmango_front/core/i18n/locale_cubit.dart';
import 'package:arrowconmango_front/features/game/presentation/screens/settings_screen.dart';
import 'package:arrowconmango_front/features/player/data/auth_token_store.dart';
import 'package:arrowconmango_front/features/player/data/session_store.dart';
import 'package:arrowconmango_front/features/player/presentation/player_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/fakes/fake_audio_service.dart';
import '../../../../helpers/player_test_setup.dart';
import '../../../../helpers/pump_localized_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late Directory sessionDir;
  late Box<dynamic> sessionBox;
  late SessionStore sessionStore;
  int boxCounter = 0;

  setUp(() async {
    sessionDir = Directory.systemTemp.createTempSync('acm_settings_session');
    Hive.init(sessionDir.path);
    sessionBox = await Hive.openBox<dynamic>('settings_session_${boxCounter++}');
    sessionStore = SessionStore(
      box: sessionBox,
      tokenStore: AuthTokenStore(box: sessionBox),
    );
  });

  tearDown(() async {
    await sessionBox.close();
    try {
      sessionDir.deleteSync(recursive: true);
    } catch (_) {}
  });

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
            ChangeNotifierProvider<SessionStore>.value(value: sessionStore),
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

  testWidgets(
    'should_show_guest_status_and_sign_in_link_when_playing_as_guest',
    (tester) async {
      // Arrange — real Hive I/O must run outside flutter_test's fake-time
      // zone, via runAsync (awaiting it directly inside a testWidgets body
      // hangs; see session_store's own plain `test()` blocks, which don't
      // have this problem because they aren't wrapped by testWidgets).
      await tester.runAsync(() => sessionStore.startGuest('guest-token'));
      final playerCubit = makePlayerCubit(name: 'MangoLoco_10');
      final audioCubit = AudioSettingsCubit(service: FakeAudioService());
      final localeCubit = LocaleCubit();
      addTearDown(playerCubit.close);
      addTearDown(audioCubit.close);
      addTearDown(localeCubit.close);

      // Act
      await pumpSettings(tester, playerCubit, audioCubit, localeCubit);

      // Assert
      expect(find.text('Jugando como invitado'), findsOneWidget);
      expect(find.text('Iniciar sesión / Crear cuenta'), findsOneWidget);
    },
  );

  testWidgets(
    'should_show_signed_in_status_and_sign_out_when_authenticated',
    (tester) async {
      // Arrange
      await tester.runAsync(() => sessionStore.startAuthenticated('account-token'));
      final playerCubit = makePlayerCubit(name: 'Ana');
      final audioCubit = AudioSettingsCubit(service: FakeAudioService());
      final localeCubit = LocaleCubit();
      addTearDown(playerCubit.close);
      addTearDown(audioCubit.close);
      addTearDown(localeCubit.close);

      // Act
      await pumpSettings(tester, playerCubit, audioCubit, localeCubit);

      // Assert
      expect(find.text('Sesión iniciada como Ana'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsOneWidget);
    },
  );

  testWidgets(
    'should_reset_session_to_none_when_signing_out',
    (tester) async {
      // Arrange
      await tester.runAsync(() => sessionStore.startAuthenticated('account-token'));
      final playerCubit = makePlayerCubit(name: 'Ana');
      final audioCubit = AudioSettingsCubit(service: FakeAudioService());
      final localeCubit = LocaleCubit();
      addTearDown(playerCubit.close);
      addTearDown(audioCubit.close);
      addTearDown(localeCubit.close);
      await pumpSettings(tester, playerCubit, audioCubit, localeCubit);

      // Act — the button's onPressed triggers real Hive I/O
      // (sessionStore.signOut()), so the whole interaction must run inside
      // runAsync or the awaited Future never resolves in the fake-async
      // test zone.
      await tester.runAsync(() async {
        await tester.tap(find.text('Cerrar sesión'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // Assert
      expect(sessionStore.mode, SessionMode.none);
    },
  );

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
