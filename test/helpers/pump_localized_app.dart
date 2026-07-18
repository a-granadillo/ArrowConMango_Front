import 'package:arrowconmango_front/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [child] wrapped in a [MaterialApp] configured with the app's
/// localizations delegates.
///
/// Use this helper for any widget test that renders UI text looked up via
/// [AppLocalizations], so the widget tree can resolve the Spanish (or English)
/// strings it expects.
Future<void> pumpLocalizedApp(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('es'),
}) {
  return tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('en')],
      home: child,
    ),
  );
}
