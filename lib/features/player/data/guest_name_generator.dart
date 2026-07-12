import 'dart:math';

/// Generates fun, random guest names and anonymous UUIDs.
///
/// Names follow the pattern `<Word><Word>_<NN>` (e.g. `MangoLoco_99`,
/// `ArrowMaster_42`), matching the Guest-First product spec.
class GuestNameGenerator {
  GuestNameGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  static const List<String> _prefixes = <String>[
    'Mango',
    'Arrow',
    'Flecha',
    'Tropi',
    'Juicy',
    'Golden',
    'Sunny',
    'Turbo',
    'Pixel',
    'Ninja',
  ];

  static const List<String> _suffixes = <String>[
    'Loco',
    'Master',
    'Star',
    'Hero',
    'Pro',
    'Fan',
    'King',
    'Boss',
    'Wizard',
    'Champ',
  ];

  /// Returns a random display name such as `MangoLoco_99`.
  String generateName() {
    final prefix = _prefixes[_random.nextInt(_prefixes.length)];
    final suffix = _suffixes[_random.nextInt(_suffixes.length)];
    final number = _random.nextInt(100).toString().padLeft(2, '0');
    return '$prefix${suffix}_$number';
  }

  /// Returns a random RFC-4122 version-4 UUID.
  String generateUuid() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    // Set version (4) and variant (10xx) bits.
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String hex(int start, int end) {
      final buffer = StringBuffer();
      for (var i = start; i < end; i++) {
        buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
      }
      return buffer.toString();
    }

    return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
  }
}
