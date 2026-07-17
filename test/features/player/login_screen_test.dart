import 'package:arrowconmango_front/features/player/presentation/bloc/auth_cubit.dart';
import 'package:arrowconmango_front/features/player/presentation/bloc/auth_state.dart';
import 'package:arrowconmango_front/features/player/presentation/screens/login_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_localized_app.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late _MockAuthCubit cubit;

  Future<void> pumpLogin(WidgetTester tester, {AuthState? state}) {
    whenListen(
      cubit,
      const Stream<AuthState>.empty(),
      initialState: state ?? const AuthInitial(),
    );
    return pumpLocalizedApp(
      tester,
      BlocProvider<AuthCubit>.value(value: cubit, child: const LoginScreen()),
    );
  }

  setUp(() {
    cubit = _MockAuthCubit();
  });

  testWidgets('should_render_email_and_password_fields', (tester) async {
    // Act
    await pumpLogin(tester);
    await tester.pump();

    // Assert
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets(
    'should_show_validation_errors_when_submitting_empty_form',
    (tester) async {
      // Arrange
      await pumpLogin(tester);
      await tester.pump();

      // Act
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Assert — the cubit is never called with invalid input.
      expect(find.text('Ingresa un correo válido'), findsOneWidget);
      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
      verifyNever(
        () => cubit.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    },
  );

  testWidgets(
    'should_call_login_with_the_entered_credentials_when_the_form_is_valid',
    (tester) async {
      // Arrange
      when(() => cubit.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {});
      await pumpLogin(tester);
      await tester.pump();

      // Act
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo electrónico'),
        'ana@test.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        'secret123',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Assert
      verify(() => cubit.login(
            email: 'ana@test.com',
            password: 'secret123',
          )).called(1);
    },
  );

  testWidgets('should_show_a_loading_indicator_while_authenticating',
      (tester) async {
    // Act
    await pumpLogin(tester, state: const AuthLoading());
    await tester.pump();

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Entrar'), findsNothing);
  });

  testWidgets('should_show_a_snackbar_with_the_failure_message',
      (tester) async {
    // Arrange
    whenListen(
      cubit,
      Stream.fromIterable(const [AuthFailure('Correo o contraseña incorrectos.')]),
      initialState: const AuthInitial(),
    );

    // Act
    await pumpLocalizedApp(
      tester,
      BlocProvider<AuthCubit>.value(value: cubit, child: const LoginScreen()),
    );
    await tester.pump();

    // Assert
    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
  });
}
