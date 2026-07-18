import 'package:arrowconmango_front/features/game/presentation/widgets/game_controls_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_localized_app.dart';

void main() {
  Future<void> pumpControls(
    WidgetTester tester, {
    required bool canUndo,
    required VoidCallback onUndo,
  }) {
    return pumpLocalizedApp(
      tester,
      Scaffold(
        body: GameControlsWidget(canUndo: canUndo, onUndo: onUndo),
      ),
    );
  }

  testWidgets('should_hide_undo_pill_when_cannot_undo', (tester) async {
    // Arrange
    var undoCalls = 0;

    // Act
    await pumpControls(tester, canUndo: false, onUndo: () => undoCalls++);

    // Assert: restart moved to the header (design), so only the undo pill
    // is owned by this widget — and it is hidden while there's nothing to undo.
    expect(find.text('Deshacer'), findsNothing);
    expect(undoCalls, 0);
  });

  testWidgets('should_fire_onUndo_when_the_pill_is_tapped', (tester) async {
    // Arrange
    var undoCalls = 0;
    await pumpControls(tester, canUndo: true, onUndo: () => undoCalls++);

    // Act
    await tester.tap(find.text('Deshacer'));
    await tester.pump();

    // Assert
    expect(undoCalls, 1);
  });
}
