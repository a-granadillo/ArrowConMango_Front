import 'guest_player.dart';

/// Port for reading and persisting the local guest player identity.
///
/// Keeps [PlayerCubit] decoupled from the concrete Hive implementation, so it
/// can be driven by an in-memory fake in tests.
abstract interface class IPlayerRepository {
  /// Returns the persisted guest, creating one on first launch.
  GuestPlayer getOrCreate();

  /// Persists a new display name for the current guest.
  Future<void> saveDisplayName(String displayName);
}
