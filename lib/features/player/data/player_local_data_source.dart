// ignore_for_file: prefer_initializing_formals
// Named params are assigned to private fields so the public API stays clean.

import 'package:hive/hive.dart';

import '../domain/guest_player.dart';
import '../domain/i_player_repository.dart';
import 'guest_name_generator.dart';

/// Persists the local guest player (uuid + display name) in a Hive box.
///
/// Stores plain string primitives, so no [TypeAdapter] is required.
class PlayerLocalDataSource implements IPlayerRepository {
  PlayerLocalDataSource({
    required Box<dynamic> box,
    required GuestNameGenerator nameGenerator,
  })  : _box = box,
        _nameGenerator = nameGenerator;

  /// Name of the Hive box that backs the player identity.
  static const String boxName = 'player';

  static const String _uuidKey = 'uuid';
  static const String _displayNameKey = 'displayName';

  final Box<dynamic> _box;
  final GuestNameGenerator _nameGenerator;

  /// Returns the persisted guest, creating and storing one on first launch.
  @override
  GuestPlayer getOrCreate() {
    final existingUuid = _box.get(_uuidKey) as String?;
    final existingName = _box.get(_displayNameKey) as String?;

    if (existingUuid != null && existingName != null) {
      return GuestPlayer(uuid: existingUuid, displayName: existingName);
    }

    final player = GuestPlayer(
      uuid: existingUuid ?? _nameGenerator.generateUuid(),
      displayName: existingName ?? _nameGenerator.generateName(),
    );
    _box.put(_uuidKey, player.uuid);
    _box.put(_displayNameKey, player.displayName);
    return player;
  }

  /// Persists a new [displayName] for the current guest.
  @override
  Future<void> saveDisplayName(String displayName) async {
    await _box.put(_displayNameKey, displayName);
  }
}
