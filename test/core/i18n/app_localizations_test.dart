import 'package:arrowconmango_front/core/i18n/app_localizations_extension.dart';
import 'package:arrowconmango_front/core/i18n/locale_cubit.dart';
import 'package:arrowconmango_front/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildApp(Locale locale) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('en')],
      home: Builder(
        builder: (context) => Text(context.l10n.menuSettings),
      ),
    );
  }

  testWidgets(
    'when locale is Spanish, then AppLocalizations resolves Spanish keys',
    (tester) async {
      // Arrange
      const locale = Locale('es');

      // Act
      await tester.pumpWidget(buildApp(locale));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ajustes'), findsOneWidget);
    },
  );

  testWidgets(
    'when locale is English, then AppLocalizations resolves English keys',
    (tester) async {
      // Arrange
      const locale = Locale('en');

      // Act
      await tester.pumpWidget(buildApp(locale));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Settings'), findsOneWidget);
    },
  );

  testWidgets(
    'when LocaleCubit emits English, then app rebuilds with English locale',
    (tester) async {
      // Arrange
      final localeCubit = LocaleCubit();
      addTearDown(localeCubit.close);

      await tester.pumpWidget(
        BlocProvider<LocaleCubit>.value(
          value: localeCubit,
          child: BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) => MaterialApp(
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('es'), Locale('en')],
              home: Builder(
                builder: (context) => Text(context.l10n.menuSettings),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ajustes'), findsOneWidget);

      // Act
      localeCubit.setLocale(const Locale('en'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Settings'), findsOneWidget);
    },
  );
}
