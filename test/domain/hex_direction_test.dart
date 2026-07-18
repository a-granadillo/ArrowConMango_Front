import 'package:arrowconmango_front/features/game/domain/entities/direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/hex_direction.dart';
import 'package:test/test.dart';

void main() {
  group('HexDirection', () {
    test('should_have_exactly_6_values', () {
      expect(HexDirection.values, hasLength(6));
      expect(
        HexDirection.values,
        containsAll([
          HexDirection.n,
          HexDirection.ne,
          HexDirection.se,
          HexDirection.s,
          HexDirection.sw,
          HexDirection.nw,
        ]),
      );
    });

    test('should_implement_direction_marker_interface', () {
      for (final direction in HexDirection.values) {
        expect(direction, isA<Direction>());
      }
    });

    test('should_expose_label_matching_enum_name', () {
      for (final direction in HexDirection.values) {
        expect(direction.label, equals(direction.name));
      }
    });
  });
}
