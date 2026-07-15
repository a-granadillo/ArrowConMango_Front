import 'package:arrowconmango_front/features/game/domain/entities/direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/spatial_direction.dart';
import 'package:test/test.dart';

void main() {
  group('SpatialDirection', () {
    test('should_have_exactly_6_orthogonal_values', () {
      expect(SpatialDirection.values, hasLength(6));
      expect(
        SpatialDirection.values,
        containsAll([
          SpatialDirection.up,
          SpatialDirection.down,
          SpatialDirection.left,
          SpatialDirection.right,
          SpatialDirection.fwd,
          SpatialDirection.back,
        ]),
      );
    });

    test('should_implement_direction_marker_interface', () {
      for (final direction in SpatialDirection.values) {
        expect(direction, isA<Direction>());
      }
    });

    test('should_expose_label_matching_enum_name', () {
      for (final direction in SpatialDirection.values) {
        expect(direction.label, equals(direction.name));
      }
    });
  });
}
