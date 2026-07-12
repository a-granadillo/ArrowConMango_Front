import 'dart:math';

import 'package:arrowconmango_front/features/player/data/guest_name_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GuestNameGenerator', () {
    test('should_generate_name_matching_word_word_number_pattern', () {
      // Arrange
      final generator = GuestNameGenerator(random: Random(1));

      // Act
      final name = generator.generateName();

      // Assert
      expect(name, matches(RegExp(r'^[A-Za-z]+_\d{2}$')));
    });

    test('should_generate_valid_v4_uuid', () {
      // Arrange
      final generator = GuestNameGenerator(random: Random(2));

      // Act
      final uuid = generator.generateUuid();

      // Assert
      expect(
        uuid,
        matches(RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        )),
      );
    });

    test('should_be_deterministic_when_seeded_with_same_random', () {
      // Arrange
      final a = GuestNameGenerator(random: Random(42));
      final b = GuestNameGenerator(random: Random(42));

      // Act & Assert
      expect(a.generateName(), b.generateName());
      expect(a.generateUuid(), b.generateUuid());
    });
  });
}
