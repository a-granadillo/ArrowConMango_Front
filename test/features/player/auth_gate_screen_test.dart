import 'package:arrowconmango_front/features/player/presentation/bloc/auth_cubit.dart';
import 'package:arrowconmango_front/features/player/presentation/bloc/auth_state.dart';
import 'package:arrowconmango_front/features/player/presentation/screens/auth_gate_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../helpers/pump_localized_app.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late _MockAuthCubit cubit;

  setUp(() {
    cubit = _MockAuthCubit();
    whenListen(
      cubit,
      const Stream<AuthState>.empty(),
      initialState: const AuthInitial(),
    );
  });

  Future<void> pumpGate(WidgetTester tester) {
    return pumpLocalizedApp(
      tester,
      BlocProvider<AuthCubit>.value(
        value: cubit,
        child: const AuthGateScreen(),
      ),
    );
  }

  testWidgets(
    'should_show_the_three_entry_points',
    (tester) async {
      // Act
      await pumpGate(tester);
      await tester.pump();

      // Assert
      expect(find.text('¡Bienvenido!'), findsOneWidget);
      expect(find.text('Crear cuenta'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.text('Jugar como invitado'), findsOneWidget);
    },
  );

  // Tapping any of the three actions calls into go_router (context.push /
  // context.go), which isn't wired in this plain-MaterialApp render test —
  // consistent with the rest of the suite (see main_menu_screen_test.dart),
  // navigation itself is intentionally not exercised at the widget level.
}
