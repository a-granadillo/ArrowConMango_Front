import 'package:arrowconmango_front/features/game/presentation/widgets/game_controls_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpControls(
    WidgetTester tester, {
    required bool canUndo,
    required VoidCallback onUndo,
    required VoidCallback onRestart,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameControlsWidget(
            canUndo: canUndo,
            onUndo: onUndo,
            onRestart: onRestart,
          ),
        ),
      ),
    );
  }

  testWidgets('should_disable_undo_when_cannot_undo', (tester) async {
    // Arrange
    var undoCalls = 0;
    await pumpControls(
      tester,
      canUndo: false,
      onUndo: () => undoCalls++,
      onRestart: () {},
    );

    // Act
    await tester.tap(find.text('Deshacer'));
    await tester.pump();

    // Assert: disabled button ignores the tap.
    expect(undoCalls, 0);
  });

  testWidgets('should_fire_callbacks_when_enabled', (tester) async {
    // Arrange
    var undoCalls = 0;
    var restartCalls = 0;
    await pumpControls(
      tester,
      canUndo: true,
      onUndo: () => undoCalls++,
      onRestart: () => restartCalls++,
    );

    // Act
    await tester.tap(find.text('Deshacer'));
    await tester.tap(find.text('Reiniciar'));
    await tester.pump();

    // Assert
    expect(undoCalls, 1);
    expect(restartCalls, 1);
  });
}
