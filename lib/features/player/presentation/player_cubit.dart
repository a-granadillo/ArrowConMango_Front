// ignore_for_file: prefer_initializing_formals
// Named param assigned to a private field to keep the public API clean.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/guest_player.dart';
import '../domain/i_player_repository.dart';

/// Exposes the current guest player to the UI and handles local renames.
///
/// The state is the current [GuestPlayer]; it is seeded at app bootstrap from
/// [IPlayerRepository.getOrCreate].
class PlayerCubit extends Cubit<GuestPlayer> {
  PlayerCubit({
    required IPlayerRepository dataSource,
    required GuestPlayer initial,
  })  : _dataSource = dataSource,
        super(initial);

  final IPlayerRepository _dataSource;

  /// Updates and persists the player's public display name.
  ///
  /// Blank names are ignored so the player always keeps a valid identity.
  Future<void> rename(String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed == state.displayName) return;
    await _dataSource.saveDisplayName(trimmed);
    emit(state.copyWith(displayName: trimmed));
  }
}
