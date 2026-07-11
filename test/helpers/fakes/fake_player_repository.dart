import 'package:arrowconmango_front/features/player/domain/guest_player.dart';
import 'package:arrowconmango_front/features/player/domain/i_player_repository.dart';

/// In-memory [IPlayerRepository] for synchronous widget tests (no Hive).
class FakePlayerRepository implements IPlayerRepository {
  FakePlayerRepository(this._player);

  GuestPlayer _player;

  @override
  GuestPlayer getOrCreate() => _player;

  @override
  Future<void> saveDisplayName(String displayName) async {
    _player = _player.copyWith(displayName: displayName);
  }
}
