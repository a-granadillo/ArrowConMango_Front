import 'package:arrowconmango_front/features/game/presentation/widgets/animations/arrow_impact_animation.dart';
import 'package:arrowconmango_front/features/game/presentation/widgets/painting/arrow_impact_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/game_test_setup.dart';

void main() {
  Future<void> pumpImpact(WidgetTester tester, {required VoidCallback onDone}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 160,
              height: 160, // a 4x4 board at cell 40
              // A straight horizontal arrow — the exact shape that used to
              // be silently skipped by ArrowImpactPainter's buggy bounds
              // check (see arrow_geometry_test.dart).
              child: ArrowImpactAnimation(
                arrow: horizontalArrow('a1', row: 0),
                cell: 40,
                onComplete: onDone,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('should_paint_with_the_impact_painter_for_a_straight_arrow',
      (tester) async {
    // Act
    await pumpImpact(tester, onDone: () {});

    // Assert
    expect(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is ArrowImpactPainter,
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('should_call_onComplete_after_the_impact_flash', (tester) async {
    // Arrange
    var completed = false;
    await pumpImpact(tester, onDone: () => completed = true);

    // Assert: not done immediately.
    expect(completed, isFalse);

    // Act: advance past the 350ms flash.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    // Assert
    expect(completed, isTrue);
  });
}
