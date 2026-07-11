import 'package:arrowconmango_front/features/game/presentation/widgets/animations/arrow_exit_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/game_test_setup.dart';

void main() {
  testWidgets('should_call_onComplete_after_the_exit_animation',
      (tester) async {
    // Arrange
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 80,
              height: 40,
              child: ArrowExitAnimation(
                arrow: horizontalArrow('a1'),
                cellSize: 40,
                color: Colors.orange,
                onComplete: () => completed = true,
              ),
            ),
          ),
        ),
      ),
    );

    // Assert: not done immediately.
    expect(completed, isFalse);

    // Act: advance past the 320ms animation.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    // Assert
    expect(completed, isTrue);
  });
}
