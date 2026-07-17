import 'package:arrowconmango_front/features/player/presentation/bloc/auth_cubit.dart';
import 'package:arrowconmango_front/features/player/presentation/bloc/auth_state.dart';
import 'package:arrowconmango_front/features/player/presentation/screens/register_screen.dart';
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

  Future<void> pumpRegister(WidgetTester tester, {AuthState? state}) {
    whenListen(
      cubit,
      const Stream<AuthState>.empty(),
      initialState: state ?? const AuthInitial(),
    );
    return pumpLocalizedApp(
      tester,
      BlocProvider<AuthCubit>.value(
        value: cubit,
        child: const RegisterScreen(),
      ),
    );
  }

  setUp(() {
    cubit = _MockAuthCubit();
  });

  testWidgets(
    'should_render_username_email_and_password_fields',
    (tester) async {
      // Act
      await pumpRegister(tester);
      await tester.pump();

      // Assert
      expect(find.text('Nombre de jugador'), findsOneWidget);
      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Registrarme'), findsOneWidget);
    },
  );

  testWidgets(
    'should_show_validation_errors_when_submitting_empty_form',
    (tester) async {
      // Arrange
      await pumpRegister(tester);
      await tester.pump();

      // Act
      await tester.tap(find.text('Registrarme'));
      await tester.pump();

      // Assert
      expect(find.text('Mínimo 2 caracteres'), findsOneWidget);
      expect(find.text('Ingresa un correo válido'), findsOneWidget);
      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
      verifyNever(
        () => cubit.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          username: any(named: 'username'),
        ),
      );
    },
  );

  testWidgets(
    'should_call_register_with_the_entered_data_when_the_form_is_valid',
    (tester) async {
      // Arrange
      when(() => cubit.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            username: any(named: 'username'),
          )).thenAnswer((_) async {});
      await pumpRegister(tester);
      await tester.pump();

      // Act
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre de jugador'),
        'Ana',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo electrónico'),
        'ana@test.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        'secret123',
      );
      await tester.tap(find.text('Registrarme'));
      await tester.pump();

      // Assert
      verify(() => cubit.register(
            email: 'ana@test.com',
            password: 'secret123',
            username: 'Ana',
          )).called(1);
    },
  );

  testWidgets('should_show_a_snackbar_when_the_email_is_already_taken',
      (tester) async {
    // Arrange
    whenListen(
      cubit,
      Stream.fromIterable(const [AuthFailure('Ese correo ya está registrado.')]),
      initialState: const AuthInitial(),
    );

    // Act
    await pumpLocalizedApp(
      tester,
      BlocProvider<AuthCubit>.value(
        value: cubit,
        child: const RegisterScreen(),
      ),
    );
    await tester.pump();

    // Assert
    expect(find.text('Ese correo ya está registrado.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
  });
}
