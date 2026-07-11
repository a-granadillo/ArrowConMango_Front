// Basic smoke test for the shared MangoBackground scaffold.
import 'package:arrowconmango_front/core/widgets/mango_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('should_render_child_when_wrapped_in_MangoBackground',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MangoBackground(child: Text('hola')),
      ),
    );

    expect(find.text('hola'), findsOneWidget);
  });
}
