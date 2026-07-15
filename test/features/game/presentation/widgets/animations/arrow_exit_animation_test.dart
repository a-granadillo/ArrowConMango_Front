import 'package:arrowconmango_front/features/game/presentation/widgets/animations/arrow_exit_animation.dart';
import 'package:arrowconmango_front/features/game/presentation/widgets/painting/arrow_exit_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/game_test_setup.dart';

void main() {
  Future<void> pumpExit(WidgetTester tester, {required VoidCallback onDone}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 160,
              height: 160, // a 4x4 board at cell 40
              child: ArrowExitAnimation(
                arrow: horizontalArrow('a1', row: 0),
                cell: 40,
                rows: 4,
                cols: 4,
                color: Colors.orange,
                onComplete: onDone,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('should_paint_with_the_exit_painter', (tester) async {
    // Act
    await pumpExit(tester, onDone: () {});

    // Assert
    expect(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is ArrowExitPainter,
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('should_call_onComplete_after_the_exit_animation',
      (tester) async {
    // Arrange
    var completed = false;
    await pumpExit(tester, onDone: () => completed = true);

    // Assert: not done immediately.
    expect(completed, isFalse);

    // Act: advance past the (clamped ≤ 700ms) animation.
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();

    // Assert
    expect(completed, isTrue);
  });
}
