import 'dart:async';

import 'package:arrowconmango_front/features/game/data/datasources/remote_progress_data_source.dart';
import 'package:arrowconmango_front/features/game/data/models/app_progress_model.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/app_progress_mapper.dart';
import 'package:arrowconmango_front/features/game/data/repositories/hive_progress_repository.dart';
import 'package:arrowconmango_front/features/game/data/repositories/synced_progress_repository.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/game/domain/services/move_based_scoring.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockHiveProgressRepository extends Mock
    implements HiveProgressRepository {}

class _MockRemoteProgressDataSource extends Mock
    implements RemoteProgressDataSource {}

class _MockConnectivity extends Mock implements Connectivity {}

class _FakePendingBox extends Fake implements Box<dynamic> {
  final Map<dynamic, dynamic> _data = {};

  @override
  dynamic get(dynamic key, {dynamic defaultValue}) =>
      _data.containsKey(key) ? _data[key] : defaultValue;

  @override
  Future<void> put(dynamic key, dynamic value) async {
    _data[key] = value;
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(const AppProgress());
    registerFallbackValue(
      const AppProgressModel(currentLevel: 0, completedLevels: []),
    );
  });

  late _MockHiveProgressRepository local;
  late _MockRemoteProgressDataSource remote;
  late _MockConnectivity connectivity;
  late _FakePendingBox pendingBox;
  late StreamController<List<ConnectivityResult>> connectivityController;
  const mapper = AppProgressMapper();
  const scoringStrategy = MoveBasedScoring();

  setUp(() {
    local = _MockHiveProgressRepository();
    remote = _MockRemoteProgressDataSource();
    connectivity = _MockConnectivity();
    pendingBox = _FakePendingBox();
    connectivityController = StreamController<List<ConnectivityResult>>();
    when(() => connectivity.onConnectivityChanged)
        .thenAnswer((_) => connectivityController.stream);
  });

  tearDown(() => connectivityController.close());

  SyncedProgressRepository buildRepo() {
    return SyncedProgressRepository(
      local: local,
      remote: remote,
      mapper: mapper,
      connectivity: connectivity,
      scoringStrategy: scoringStrategy,
      pendingFlagBox: pendingBox,
    );
  }

  group('saveProgress', () {
    test('should_push_to_remote_and_not_mark_pending_when_online', () async {
      when(() => local.saveProgress(any()))
          .thenAnswer((_) async => const Success<void>(null));
      when(() => remote.push(any())).thenAnswer(
        (_) async => const AppProgressModel(currentLevel: 1, completedLevels: [1]),
      );
      final repo = buildRepo();
      const progress = AppProgress(unlockedLevels: [1], currentLevel: 1);

      final result = await repo.saveProgress(progress);
      await Future.delayed(Duration.zero); // Wait for async push

      expect(result, isA<Success<void>>());
      verify(() => local.saveProgress(progress)).called(1);
      verify(() => remote.push(any())).called(1);
      expect(pendingBox.get('progress_sync_pending'), isFalse);
    });

    test('should_save_locally_and_mark_pending_when_remote_push_fails',
        () async {
      when(() => local.saveProgress(any()))
          .thenAnswer((_) async => const Success<void>(null));
      when(() => remote.push(any())).thenThrow(Exception('offline'));
      final repo = buildRepo();
      const progress = AppProgress(unlockedLevels: [1], currentLevel: 1);

      final result = await repo.saveProgress(progress);
      await Future.delayed(Duration.zero); // Wait for async push

      expect(result, isA<Success<void>>());
      verify(() => local.saveProgress(progress)).called(1);
      expect(pendingBox.get('progress_sync_pending'), isTrue);
    });

    test('should_not_attempt_remote_push_when_local_save_fails', () async {
      when(() => local.saveProgress(any())).thenAnswer(
        (_) async => const Error<void>(GenericFailure('disk full')),
      );
      final repo = buildRepo();

      final result = await repo.saveProgress(const AppProgress());

      expect(result, isA<Error<void>>());
      verifyNever(() => remote.push(any()));
    });
  });

  group('reconnection flush', () {
    test('should_flush_pending_progress_when_connectivity_is_restored',
        () async {
      when(() => local.saveProgress(any()))
          .thenAnswer((_) async => const Success<void>(null));
      when(() => remote.push(any())).thenThrow(Exception('offline'));
      final repo = buildRepo();
      const progress = AppProgress(unlockedLevels: [1], currentLevel: 1);
      await repo.saveProgress(progress);
      await Future<void>.delayed(Duration.zero); // Wait for async push
      expect(pendingBox.get('progress_sync_pending'), isTrue);

      // Backend becomes reachable.
      when(() => local.loadProgress())
          .thenAnswer((_) async => const Success<AppProgress>(progress));
      when(() => remote.push(any())).thenAnswer(
        (_) async => const AppProgressModel(currentLevel: 1, completedLevels: [1]),
      );
      connectivityController.add([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(pendingBox.get('progress_sync_pending'), isFalse);
      verify(() => remote.push(any())).called(greaterThanOrEqualTo(1));
    });

    test('should_flush_pending_progress_on_startup_when_flag_already_set',
        () async {
      await pendingBox.put('progress_sync_pending', true);
      const progress = AppProgress(unlockedLevels: [2], currentLevel: 2);
      when(() => local.loadProgress())
          .thenAnswer((_) async => const Success<AppProgress>(progress));
      when(() => remote.push(any())).thenAnswer(
        (_) async => const AppProgressModel(currentLevel: 2, completedLevels: [2]),
      );

      buildRepo();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      verify(() => remote.push(any())).called(1);
      expect(pendingBox.get('progress_sync_pending'), isFalse);
    });
  });

  group('loadProgress', () {
    test('should_merge_remote_and_local_progress_when_remote_succeeds',
        () async {
      const localProgress = AppProgress(unlockedLevels: [1], currentLevel: 1);
      when(() => local.loadProgress())
          .thenAnswer((_) async => const Success<AppProgress>(localProgress));
      when(() => local.saveProgress(any()))
          .thenAnswer((_) async => const Success<void>(null));
      when(() => remote.fetch()).thenAnswer(
        (_) async =>
            const AppProgressModel(currentLevel: 3, completedLevels: [2, 3]),
      );
      final repo = buildRepo();

      final result = await repo.loadProgress();

      expect(result, isA<Success<AppProgress>>());
      final merged = (result as Success<AppProgress>).value;
      expect(merged.unlockedLevels, equals([1, 2, 3]));
      expect(merged.currentLevel, equals(3));
      verify(() => local.saveProgress(merged)).called(1);
    });

    test('should_fall_back_to_local_progress_when_remote_fetch_fails',
        () async {
      const localProgress = AppProgress(unlockedLevels: [1], currentLevel: 1);
      when(() => local.loadProgress())
          .thenAnswer((_) async => const Success<AppProgress>(localProgress));
      when(() => remote.fetch()).thenThrow(Exception('offline'));
      final repo = buildRepo();

      final result = await repo.loadProgress();

      expect(result, isA<Success<AppProgress>>());
      expect((result as Success<AppProgress>).value, equals(localProgress));
    });
  });
}
