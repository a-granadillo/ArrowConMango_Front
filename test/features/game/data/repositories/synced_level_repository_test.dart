import 'dart:async';

import 'package:arrowconmango_front/features/game/data/datasources/remote_level_data_source.dart';
import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/arrow_trajectory.dart';
import 'package:arrowconmango_front/features/game/data/models/board_size_model.dart';
import 'package:arrowconmango_front/features/game/data/models/board_state_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';
import 'package:arrowconmango_front/features/game/data/models/trajectory_segment.dart';
import 'package:arrowconmango_front/features/game/data/repositories/hive_level_repository.dart';
import 'package:arrowconmango_front/features/game/data/repositories/synced_level_repository.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockHiveLevelRepository extends Mock implements HiveLevelRepository {}

class _MockRemoteLevelDataSource extends Mock
    implements RemoteLevelDataSource {}

class _MockConnectivity extends Mock implements Connectivity {}

class _FakeLevelsBox extends Fake implements Box<LevelModel> {
  final Map<int, LevelModel> _data = {};

  @override
  Future<void> putAll(Map<dynamic, LevelModel> entries) async {
    _data.addAll(entries.cast<int, LevelModel>());
  }

  @override
  LevelModel? get(dynamic key, {LevelModel? defaultValue}) =>
      _data[key] ?? defaultValue;
}

LevelModel _makeLevel(int id) => LevelModel(
      id: id,
      name: 'Level $id',
      difficulty: 'Easy',
      boardSize: const BoardSizeModel(rows: 2, cols: 2),
      boardState: const BoardStateModel(
        arrows: [
          ArrowModel(
            id: 'a1',
            startNode: NodeModel(row: 0, col: 0),
            trajectory: ArrowTrajectory(
              segments: [
                TrajectorySegment(direction: CardinalDirection.right, length: 2),
              ],
            ),
          ),
        ],
      ),
    );

void main() {
  late _MockHiveLevelRepository local;
  late _MockRemoteLevelDataSource remote;
  late _MockConnectivity connectivity;
  late _FakeLevelsBox levelsBox;
  late StreamController<List<ConnectivityResult>> connectivityController;

  setUp(() {
    local = _MockHiveLevelRepository();
    remote = _MockRemoteLevelDataSource();
    connectivity = _MockConnectivity();
    levelsBox = _FakeLevelsBox();
    connectivityController = StreamController<List<ConnectivityResult>>();
    when(() => connectivity.onConnectivityChanged)
        .thenAnswer((_) => connectivityController.stream);
  });

  tearDown(() => connectivityController.close());

  SyncedLevelRepository buildRepo() {
    return SyncedLevelRepository(
      local: local,
      remote: remote,
      levelsBox: levelsBox,
      connectivity: connectivity,
    );
  }

  test('should_write_fetched_levels_into_the_box_when_remote_succeeds',
      () async {
    when(() => remote.fetchAll()).thenAnswer((_) async => [_makeLevel(1)]);

    buildRepo();
    await Future.delayed(Duration.zero);

    expect(levelsBox.get(1)?.name, 'Level 1');
  });

  test('should_leave_the_box_untouched_when_remote_fails', () async {
    when(() => remote.fetchAll()).thenThrow(Exception('offline'));

    buildRepo();
    await Future.delayed(Duration.zero);

    expect(levelsBox.get(1), isNull);
  });

  test('should_resync_when_connectivity_is_restored', () async {
    when(() => remote.fetchAll()).thenAnswer((_) async => [_makeLevel(2)]);

    buildRepo();
    await Future.delayed(Duration.zero);

    connectivityController.add([ConnectivityResult.wifi]);
    await Future.delayed(Duration.zero);

    verify(() => remote.fetchAll()).called(2);
  });

  test('should_delegate_reads_to_the_local_repository', () async {
    when(() => remote.fetchAll()).thenAnswer((_) async => []);
    when(() => local.getLevelCount())
        .thenAnswer((_) async => const Success<int>(15));

    final repo = buildRepo();
    final result = await repo.getLevelCount();

    expect(result, isA<Success<int>>());
    verify(() => local.getLevelCount()).called(1);
  });
}
