// ignore_for_file: prefer_initializing_formals
// Named params are assigned to private fields so the public API stays clean.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/game_session.dart';
import '../../domain/entities/level.dart';
import '../../domain/repositories/i_level_repository.dart';
import '../../domain/repositories/result.dart';
import '../datasources/remote_level_data_source.dart';
import '../models/level_model.dart';
import 'hive_level_repository.dart';

/// Decorates [HiveLevelRepository] with backend sync.
///
/// Reads always come from the local Hive box, so the campaign catalogue is
/// always available offline (it's seeded at first launch — see
/// `_seedLevels` in the composition root). On construction and whenever
/// connectivity is restored, this fetches `GET /levels` in the background
/// and overwrites the local entries with the backend's copy, so the
/// backend becomes the source of truth for campaign levels whenever it's
/// reachable, without ever blocking a read on the network.
@LazySingleton(as: ILevelRepository)
class SyncedLevelRepository implements ILevelRepository {
  SyncedLevelRepository({
    required HiveLevelRepository local,
    required RemoteLevelDataSource remote,
    required Box<LevelModel> levelsBox,
    required Connectivity connectivity,
  })  : _local = local,
        _remote = remote,
        _levelsBox = levelsBox {
    connectivity.onConnectivityChanged.listen((results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        _syncFromRemote();
      }
    });
    _syncFromRemote();
  }

  final HiveLevelRepository _local;
  final RemoteLevelDataSource _remote;
  final Box<LevelModel> _levelsBox;

  Future<void> _syncFromRemote() async {
    try {
      final levels = await _remote.fetchAll().timeout(
            const Duration(seconds: 5),
          );
      if (levels.isEmpty) return;

      await _levelsBox.putAll({
        for (final level in levels) level.id: level,
      });
    } catch (_) {
      // Offline or unreachable — the box already has the bundled catalogue.
    }
  }

  @override
  Future<Result<GameSession>> loadLevel(int levelId) =>
      _local.loadLevel(levelId);

  @override
  Future<Result<int>> getLevelCount() => _local.getLevelCount();

  @override
  Future<Result<Level>> getLevelDefinition(int levelId) =>
      _local.getLevelDefinition(levelId);
}
