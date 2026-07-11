import 'package:arrowconmango_front/features/game/presentation/widgets/arrow_widget.dart';
import 'package:arrowconmango_front/features/game/presentation/widgets/board_grid_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/game_test_setup.dart';

void main() {
  Future<void> pumpBoard(
    WidgetTester tester, {
    required void Function(String) onTap,
  }) {
    final arrows = [
      horizontalArrow('a1', row: 0),
      horizontalArrow('a2', row: 2),
    ];
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 320,
              child: BoardGridWidget(
                rows: 4,
                cols: 4,
                arrows: arrows,
                onArrowTap: onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('should_render_one_ArrowWidget_per_arrow', (tester) async {
    // Act
    await pumpBoard(tester, onTap: (_) {});

    // Assert
    expect(find.byType(ArrowWidget), findsNWidgets(2));
  });

  testWidgets('should_report_arrow_id_when_tapped', (tester) async {
    // Arrange
    String? tapped;
    await pumpBoard(tester, onTap: (id) => tapped = id);

    // Act: the first arrow in the list occupies row 0.
    await tester.tap(find.byType(ArrowWidget).first);
    await tester.pump();

    // Assert
    expect(tapped, 'a1');
  });
}
