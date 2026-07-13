import 'package:arrowconmango_front/features/game/presentation/screens/main_menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('should_show_title_and_navigation_actions', (tester) async {
    // Act
    await tester.pumpWidget(const MaterialApp(home: MainMenuScreen()));
    await tester.pump();

    // Assert — faithful design: two-line title + play + 3 nav buttons.
    expect(find.text('ARROW CON'), findsOneWidget);
    expect(find.text('MANGO'), findsOneWidget);
    expect(find.text('MODO CAMPAÑA'), findsOneWidget);
    expect(find.text('SUPERVIVENCIA'), findsOneWidget);
    expect(find.text('Niveles'), findsOneWidget);
    expect(find.text('Ranking'), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);

    // Dispose the screen so the mango/sparkle animation timers are cancelled.
    await tester.pumpWidget(const SizedBox());
  });
}
