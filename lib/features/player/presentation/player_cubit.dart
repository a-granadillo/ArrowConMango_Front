// ignore_for_file: prefer_initializing_formals
// Named param assigned to a private field to keep the public API clean.

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/remote_player_data_source.dart';
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
    RemotePlayerDataSource? remoteDataSource,
  })  : _dataSource = dataSource,
        _remoteDataSource = remoteDataSource,
        super(initial);

  final IPlayerRepository _dataSource;

  /// Null only for the throwaway [PlayerCubit] instance the composition root
  /// constructs before the authenticated Dio is available — it is replaced
  /// before any UI can observe it. See `service_locator.dart`.
  final RemotePlayerDataSource? _remoteDataSource;

  /// Updates and persists the player's public display name.
  ///
  /// Blank names are ignored so the player always keeps a valid identity.
  /// Also syncs the new name to the backend fire-and-forget: a failed sync
  /// must not block the local rename, consistent with the app's
  /// offline-first posture elsewhere (see SubmitScoreUseCase).
  Future<void> rename(String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed == state.displayName) return;
    await _dataSource.saveDisplayName(trimmed);
    emit(state.copyWith(displayName: trimmed));

    unawaited(_syncRemoteName(trimmed));
  }

  /// Best-effort: any failure (sync or async) is swallowed. See [rename].
  Future<void> _syncRemoteName(String displayName) async {
    final remote = _remoteDataSource;
    if (remote == null) return;
    try {
      await remote.updateDisplayName(displayName);
    } catch (_) {
      // Best-effort: swallow. See [rename].
    }
  }
}
