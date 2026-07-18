import 'package:arrowconmango_front/features/game/data/topologies/hex_graph.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/hex_direction.dart';
import 'package:arrowconmango_front/features/game/presentation/widgets/hex/hex_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

const _size = 30.0;

void main() {
  group('qr', () {
    test('parses a HexNodeId key into (q, r)', () {
      const node = HexNodeId(q: -2, r: 3);
      expect(qr(node), (-2, 3));
    });
  });

  group('axialToPixel / pixelToAxial', () {
    test('round_trips_the_origin', () {
      final pixel = axialToPixel(0, 0, _size);
      expect(pixel, const Offset(0, 0));
      expect(pixelToAxial(pixel, _size), (0, 0));
    });

    for (final coord in [(1, 0), (0, 1), (-1, 1), (2, -1), (-3, 2), (3, 0)]) {
      test('round_trips_axial_${coord.$1}_${coord.$2}', () {
        final (q, r) = coord;
        final pixel = axialToPixel(q, r, _size);
        expect(pixelToAxial(pixel, _size), (q, r));
      });
    }

    test('neighboring_hexes_are_never_closer_than_size_apart', () {
      // Sanity check on the pixel conversion's scale: two axially-adjacent
      // hex centers must be at least one hex "radius" apart, or the tap
      // hit-testing in HexBoardWidget would be ambiguous.
      final center = axialToPixel(0, 0, _size);
      final neighbor = axialToPixel(1, 0, _size);
      expect((neighbor - center).distance, greaterThan(_size));
    });
  });

  group('hexCorners', () {
    test('returns_6_corners_at_the_given_radius_from_center', () {
      const center = Offset(10, 20);
      final corners = hexCorners(center, _size);
      expect(corners, hasLength(6));
      for (final corner in corners) {
        expect((corner - center).distance, closeTo(_size, 0.001));
      }
    });
  });

  group('hex-of-hexagons board bounding box', () {
    // Regression test for a board-sizing bug: HexBoardWidget/the creative
    // editor once computed a board canvas height using `1.5*radius+2` —
    // exactly half the true extent — clipping the top and bottom rows of
    // hexagons. The true height factor is `3*radius+2`: row centers span
    // `1.5*size` each across `2*radius` rows (= `3*radius*size` total),
    // plus one hex's half-height (`size`) of margin on each side.
    for (final radius in [1, 2, 3, 5]) {
      test('every_hex_corner_fits_within_the_3R+2_height_factor_for_radius_$radius', () {
        final widthFactor = 1.7320508075688772 * (2 * radius + 1);
        final heightFactor = 3 * radius + 2;
        final maxX = widthFactor / 2 * _size;
        final maxY = heightFactor / 2 * _size;

        for (var q = -radius; q <= radius; q++) {
          final rMin = (-radius - q).clamp(-radius, radius);
          final rMax = (radius - q).clamp(-radius, radius);
          for (var r = rMin; r <= rMax; r++) {
            final center = axialToPixel(q, r, _size);
            for (final corner in hexCorners(center, _size)) {
              expect(
                corner.dx.abs(),
                lessThanOrEqualTo(maxX + 0.01),
                reason: 'q=$q r=$r corner $corner exceeds width bound $maxX',
              );
              expect(
                corner.dy.abs(),
                lessThanOrEqualTo(maxY + 0.01),
                reason: 'q=$q r=$r corner $corner exceeds height bound $maxY',
              );
            }
          }
        }
      });

      test('the_old_buggy_1_5R+2_height_factor_would_clip_corners_for_radius_$radius', () {
        // Documents *why* the fix was needed: the previous (wrong) factor
        // is provably too small to contain every corner.
        final buggyHeightFactor = 1.5 * radius + 2;
        final maxY = buggyHeightFactor / 2 * _size;

        final topCenter = axialToPixel(0, -radius, _size);
        final topCorner = hexCorners(topCenter, _size)
            .reduce((a, b) => a.dy < b.dy ? a : b); // most-negative dy
        expect(topCorner.dy.abs(), greaterThan(maxY));
      });
    }
  });

  group('unitVector', () {
    test('every_hex_direction_has_unit_length', () {
      for (final direction in HexDirection.values) {
        expect(unitVector(direction).distance, closeTo(1.0, 0.001));
      }
    });

    test('opposite_directions_point_opposite_ways', () {
      final n = unitVector(HexDirection.n);
      final s = unitVector(HexDirection.s);
      expect(n.dx, closeTo(-s.dx, 0.001));
      expect(n.dy, closeTo(-s.dy, 0.001));
    });
  });

  group('buildBodyPath', () {
    test('single_cell_arrow_has_non_empty_metrics', () {
      const a = ArrowEntity(
        id: 'a',
        direction: HexDirection.se,
        occupiedNodes: [HexNodeId(q: 0, r: 0)],
      );
      final metrics = buildBodyPath(a, _size).computeMetrics().toList();
      expect(metrics, isNotEmpty);
      expect(metrics.first.length, greaterThan(0));
    });

    test('multi_cell_body_is_a_single_contour', () {
      const a = ArrowEntity(
        id: 'a',
        direction: HexDirection.se,
        occupiedNodes: [
          HexNodeId(q: 0, r: 0),
          HexNodeId(q: 1, r: 0),
          HexNodeId(q: 2, r: 0),
        ],
      );
      final metrics = buildBodyPath(a, _size).computeMetrics().toList();
      expect(metrics, hasLength(1));
    });
  });
}
