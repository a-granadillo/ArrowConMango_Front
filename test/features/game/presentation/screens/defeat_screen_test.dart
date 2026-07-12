import 'package:arrowconmango_front/features/game/presentation/bloc/game_state.dart';
import 'package:arrowconmango_front/features/game/presentation/screens/defeat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpDefeat(WidgetTester tester, GameDefeat result) {
    return tester.pumpWidget(
      MaterialApp(home: DefeatScreen(result: result)),
    );
  }

  testWidgets('should_show_time_expired_reason_and_actions', (tester) async {
    // Arrange
    const result = GameDefeat(
      levelId: 3,
      reason: DefeatReason.timeExpired,
      moveCount: 20,
      elapsedSeconds: 60,
    );

    // Act
    await pumpDefeat(tester, result);

    // Assert
    expect(find.text('¡Oh no!'), findsOneWidget);
    expect(find.text('¡Se acabó el tiempo!'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(find.text('1:00'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Menú'), findsOneWidget);

    // Dispose the screen so its ResultSheet animation tickers are cancelled.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('should_show_no_moves_reason', (tester) async {
    // Arrange
    const result = GameDefeat(
      levelId: 2,
      reason: DefeatReason.noMovesAvailable,
      moveCount: 8,
      elapsedSeconds: 15,
    );

    // Act
    await pumpDefeat(tester, result);

    // Assert
    expect(find.text('No quedan movimientos posibles.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
