// ignore_for_file: prefer_initializing_formals
// Named params are assigned to private fields so the public API stays clean.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/app_progress.dart';
import '../../domain/entities/scoring_strategy.dart';
import '../../domain/repositories/i_progress_repository.dart';
import '../../domain/repositories/result.dart';
import '../datasources/remote_progress_data_source.dart';
import '../models/mappers/app_progress_mapper.dart';
import 'hive_progress_repository.dart';

/// Decorates [HiveProgressRepository] with backend sync.
///
/// Every save goes to Hive first, so progress is never lost even offline.
/// It then attempts to push to the backend; on failure (offline/timeout) a
/// pending flag is set and the push is retried automatically once
/// connectivity is restored. Loads merge the remote snapshot into the local
/// one (union of unlocked levels, highest current level) so a fresh install
/// picks up progress synced from another session.
@LazySingleton(as: IProgressRepository)
class SyncedProgressRepository implements IProgressRepository {
  SyncedProgressRepository({
    required HiveProgressRepository local,
    required RemoteProgressDataSource remote,
    required AppProgressMapper mapper,
    required Connectivity connectivity,
    required ScoringStrategy scoringStrategy,
    @Named('playerBox') required Box<dynamic> pendingFlagBox,
  })  : _local = local,
        _remote = remote,
        _mapper = mapper,
        _scoringStrategy = scoringStrategy,
        _pendingFlagBox = pendingFlagBox {
    connectivity.onConnectivityChanged.listen((results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        _flushPending();
      }
    });
    _flushPending();
  }

  static const String _pendingKey = 'progress_sync_pending';

  final HiveProgressRepository _local;
  final RemoteProgressDataSource _remote;
  final AppProgressMapper _mapper;
  final ScoringStrategy _scoringStrategy;
  final Box<dynamic> _pendingFlagBox;

  bool get _hasPending =>
      (_pendingFlagBox.get(_pendingKey) as bool?) ?? false;

  Future<void> _markPending(bool pending) =>
      _pendingFlagBox.put(_pendingKey, pending);

  /// Awaits [_markPending] and swallows any error so a failing Hive put can
  /// never propagate as an unhandled async exception.
  Future<void> _safeMarkPending(bool pending) async {
    try {
      await _markPending(pending);
    } catch (_) {
      // Storage failure: the pending flag may be wrong, but we cannot recover
      // synchronously here; the next load/save will reconcile the flag.
    }
  }

  @override
  Future<Result<AppProgress>> loadProgress() async {
    final localResult = await _local.loadProgress();
    final localEntity = switch (localResult) {
      Success(:final value) => value,
      Error() => const AppProgress(),
    };

    try {
      // Set a strict 500ms timeout on the remote fetch so we never block the UI
      final remoteModel = await _remote
          .fetch()
          .timeout(const Duration(milliseconds: 500));
      final remoteEntity = _mapper.toEntity(remoteModel);
      final merged = _merge(localEntity, remoteEntity);
      await _local.saveProgress(merged);
      return Success<AppProgress>(merged);
    } catch (_) {
      return localResult;
    }
  }

  @override
  Future<Result<void>> saveProgress(AppProgress progress) async {
    final localSaveResult = await _local.saveProgress(progress);
    if (localSaveResult is Error<void>) return localSaveResult;

    // Fire and forget remote push to avoid blocking the UI on victory screens.
    // Wrap in a try/catch block to robustly handle synchronous exceptions in tests.
    try {
      _remote.push(_mapper.toModel(progress)).then((_) {
        _markPending(false).catchError((_) {});
      }).catchError((_) async {
        await _safeMarkPending(true);
      });
    } catch (_) {
      await _safeMarkPending(true);
    }

    return localSaveResult;
  }

  Future<void> _flushPending() async {
    if (!_hasPending) return;

    final localResult = await _local.loadProgress();
    if (localResult is! Success<AppProgress>) return;

    try {
      await _remote.push(_mapper.toModel(localResult.value));
      await _markPending(false);
    } catch (_) {
      // Still offline/unreachable — keep the pending flag for next attempt.
    }
  }

  AppProgress _merge(AppProgress local, AppProgress remote) {
    final unlocked = {...local.unlockedLevels, ...remote.unlockedLevels}.toList()
      ..sort();
    final currentLevel = local.currentLevel > remote.currentLevel
        ? local.currentLevel
        : remote.currentLevel;

    var merged = AppProgress(unlockedLevels: unlocked, currentLevel: currentLevel);
    for (final entry in local.best.entries) {
      merged = merged.withBest(entry.key, entry.value, _scoringStrategy);
    }
    for (final entry in remote.best.entries) {
      merged = merged.withBest(entry.key, entry.value, _scoringStrategy);
    }
    return merged;
  }
}
