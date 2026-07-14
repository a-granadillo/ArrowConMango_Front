// ignore_for_file: prefer_initializing_formals
// Named params are assigned to private fields so the public API stays clean.

import 'package:hive/hive.dart';

/// Persists the user's global audio mute preference in a Hive box.
///
/// Stores a plain boolean primitive, so no [TypeAdapter] is required.
class AudioSettingsLocalDataSource {
  AudioSettingsLocalDataSource({required Box<dynamic> box}) : _box = box;

  /// Name of the Hive box that backs the audio settings.
  static const String boxName = 'audio_settings';

  static const String _mutedKey = 'muted';

  final Box<dynamic> _box;

  /// Whether audio is currently muted. Defaults to `false` (audio on).
  bool get isMuted => _box.get(_mutedKey, defaultValue: false) as bool;

  /// Persists the muted state.
  Future<void> setMuted(bool value) => _box.put(_mutedKey, value);
}
