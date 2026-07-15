import 'package:arrowconmango_front/features/game/presentation/bloc/game_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameEvent', () {
    test('LoadLevel instances with same value are equal', () {
      expect(
        const LoadLevel(levelId: 1),
        equals(const LoadLevel(levelId: 1)),
      );
    });

    test('LoadLevel instances with different values are not equal', () {
      expect(
        const LoadLevel(levelId: 1),
        isNot(equals(const LoadLevel(levelId: 2))),
      );
    });

    test('TriggerArrowExit instances with same value are equal', () {
      expect(
        const TriggerArrowExit(arrowId: 'arrow_1'),
        equals(const TriggerArrowExit(arrowId: 'arrow_1')),
      );
    });

    test('TriggerArrowExit instances with different values are not equal', () {
      expect(
        const TriggerArrowExit(arrowId: 'arrow_1'),
        isNot(equals(const TriggerArrowExit(arrowId: 'arrow_2'))),
      );
    });

    test('UndoMove instances are always equal', () {
      expect(const UndoMove(), equals(const UndoMove()));
    });

    test('Tick instances with same value are equal', () {
      expect(
        const Tick(nowMs: 1000),
        equals(const Tick(nowMs: 1000)),
      );
    });

    test('Tick instances with different values are not equal', () {
      expect(
        const Tick(nowMs: 1000),
        isNot(equals(const Tick(nowMs: 2000))),
      );
    });

    test('RetryLevel instances are always equal', () {
      expect(const RetryLevel(), equals(const RetryLevel()));
    });
  });
}
