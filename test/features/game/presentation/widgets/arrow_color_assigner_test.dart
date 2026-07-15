import 'package:arrowconmango_front/features/game/presentation/widgets/arrow_color_assigner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArrowColorAssigner', () {
    test('assigns_palette_colors_in_first_seen_order', () {
      final a = ArrowColorAssigner();
      expect(a.colorOf('x'), ArrowColorAssigner.palette[0]);
      expect(a.colorOf('y'), ArrowColorAssigner.palette[1]);
      expect(a.colorOf('z'), ArrowColorAssigner.palette[2]);
    });

    test('returns_the_same_color_for_an_id_regardless_of_removals', () {
      final a = ArrowColorAssigner();
      final cx = a.colorOf('x');
      a.colorOf('y');
      a.colorOf('z');
      // 'x' keeps its color even after other ids were seen (i.e. after the
      // live list shifted around it).
      expect(a.colorOf('x'), cx);
    });

    test('cycles_the_palette_beyond_its_length', () {
      final a = ArrowColorAssigner();
      final n = ArrowColorAssigner.palette.length;
      for (var i = 0; i < n; i++) {
        a.colorOf('id$i');
      }
      // The (n+1)-th distinct id wraps to palette[0].
      expect(a.colorOf('wrap'), ArrowColorAssigner.palette[0]);
    });

    test('reset_clears_assignments', () {
      final a = ArrowColorAssigner();
      a.colorOf('x');
      a.colorOf('y');
      a.reset();
      // After reset, the next id starts from palette[0] again.
      expect(a.colorOf('fresh'), ArrowColorAssigner.palette[0]);
    });
  });
}
