import 'package:arrowconmango_front/features/game/presentation/widgets/painting/z_axis_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

const _cell = 40.0;
const _center = Offset(100, 100);

void main() {
  group('glyphRadiusFor', () {
    test('scales_with_cell', () {
      expect(glyphRadiusFor(_cell), closeTo(_cell * 0.30, 0.001));
    });
  });

  group('glyphDotRadiusFor', () {
    test('is_smaller_than_the_ring_radius', () {
      expect(glyphDotRadiusFor(_cell), lessThan(glyphRadiusFor(_cell)));
    });
  });

  group('buildGlyphRing', () {
    test('bounding_box_is_centered_on_the_anchor', () {
      final bounds = buildGlyphRing(_center, _cell).getBounds();
      expect(bounds.center.dx, closeTo(_center.dx, 0.001));
      expect(bounds.center.dy, closeTo(_center.dy, 0.001));
      expect(bounds.width, closeTo(glyphRadiusFor(_cell) * 2, 0.001));
    });
  });

  group('buildForwardDot', () {
    test('is_a_small_filled_oval_centered_on_the_anchor', () {
      final bounds = buildForwardDot(_center, _cell).getBounds();
      expect(bounds.center.dx, closeTo(_center.dx, 0.001));
      expect(bounds.width, closeTo(glyphDotRadiusFor(_cell) * 2, 0.001));
    });
  });

  group('buildBackwardCross', () {
    test('is_two_contours_forming_an_X_inscribed_in_the_ring', () {
      final cross = buildBackwardCross(_center, _cell);
      final metrics = cross.computeMetrics().toList();
      expect(metrics, hasLength(2));

      final bounds = cross.getBounds();
      expect(
        bounds.width,
        lessThanOrEqualTo(glyphRadiusFor(_cell) * 2 + 0.001),
      );
      expect(
        bounds.height,
        lessThanOrEqualTo(glyphRadiusFor(_cell) * 2 + 0.001),
      );
    });
  });
}
