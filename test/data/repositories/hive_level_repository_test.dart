import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/board_state_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/arrow_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/board_state_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/level_mapper.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';
import 'package:arrowconmango_front/features/game/data/repositories/hive_level_repository.dart';
import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:hive/hive.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';

class _FakeLevelBox extends Fake implements Box<LevelModel> {
  final Map<dynamic, LevelModel> _data = {};
  int _lengthOverride;

  _FakeLevelBox({this._lengthOverride = -1});

  void seed(int levelId, LevelModel model) {
    _data[levelId] = model;
    if (_lengthOverride < 0) {
      _lengthOverride = _data.length;
    }
  }

  @override
  LevelModel? get(dynamic key, {LevelModel? defaultValue}) {
    return _data.containsKey(key) ? _data[key] : defaultValue;
  }

  @override
  int get length => _lengthOverride >= 0 ? _lengthOverride : _data.length;

  @override
  bool containsKey(dynamic key) => _data.containsKey(key);

  @override
  Iterable<LevelModel> get values => _data.values;
}

class _ThrowingLevelBox extends Fake implements Box<LevelModel> {
  @override
  LevelModel? get(dynamic key, {LevelModel? defaultValue}) {
    throw Exception('Box read error');
  }

  @override
  int get length => throw Exception('Box length error');
}

void main() {
  const mapper = LevelMapper(BoardStateMapper(ArrowMapper()));

  group('HiveLevelRepository', () {
    test('loadLevel returns GameSession for existing level', () async {
      final box = _FakeLevelBox()
        ..seed(
          1,
          LevelModel(
            id: 1,
            name: 'Level 1',
            difficulty: 'Easy',
            boardState: BoardStateModel(
              arrows: [
                ArrowModel(
                  id: 'a1',
                  direction: 'right',
                  nodes: const [NodeModel(row: 0, col: 0)],
                ),
              ],
            ),
          ),
        );
      final repo = HiveLevelRepository(box, mapper);

      final result = await repo.loadLevel(1);

      expect(result, isA<Success<GameSession>>());
      final session = (result as Success<GameSession>).value;
      expect(session.boardState.arrowCount, equals(1));
    });

    test('loadLevel returns Error when level is missing', () async {
      final box = _FakeLevelBox();
      final repo = HiveLevelRepository(box, mapper);

      final result = await repo.loadLevel(99);

      expect(result, isA<Error<GameSession>>());
      final failure = (result as Error<GameSession>).failure;
      expect(failure, isA<GenericFailure>());
      expect(failure.message, contains('99'));
    });

    test('getLevelCount returns box length', () async {
      final box = _FakeLevelBox(lengthOverride: 5);
      final repo = HiveLevelRepository(box, mapper);

      final result = await repo.getLevelCount();

      expect(result, isA<Success<int>>());
      expect((result as Success<int>).value, equals(5));
    });

    test('getLevelDefinition returns Level for existing level', () async {
      final box = _FakeLevelBox()
        ..seed(
          2,
          LevelModel(
            id: 2,
            name: 'Level 2',
            difficulty: 'Easy',
            boardState: BoardStateModel(
              arrows: [
                ArrowModel(
                  id: 'a1',
                  direction: 'up',
                  nodes: const [NodeModel(row: 1, col: 1)],
                ),
              ],
            ),
          ),
        );
      final repo = HiveLevelRepository(box, mapper);

      final result = await repo.getLevelDefinition(2);

      expect(result, isA<Success<Level>>());
      final level = (result as Success<Level>).value;
      expect(level.levelId, equals(2));
      expect(level.templateBoard.arrowCount, equals(1));
    });

    test('getLevelDefinition returns Error when level is missing', () async {
      final box = _FakeLevelBox();
      final repo = HiveLevelRepository(box, mapper);

      final result = await repo.getLevelDefinition(42);

      expect(result, isA<Error<Level>>());
      final failure = (result as Error<Level>).failure;
      expect(failure, isA<GenericFailure>());
      expect(failure.message, contains('42'));
    });

    test('loadLevel wraps exceptions in Error', () async {
      final repo = HiveLevelRepository(
        _ThrowingLevelBox(),
        mapper,
      );

      final result = await repo.loadLevel(1);

      expect(result, isA<Error<GameSession>>());
    });

    test('getLevelCount wraps exceptions in Error', () async {
      final repo = HiveLevelRepository(
        _ThrowingLevelBox(),
        mapper,
      );

      final result = await repo.getLevelCount();

      expect(result, isA<Error<int>>());
    });

    test('getLevelDefinition wraps exceptions in Error', () async {
      final repo = HiveLevelRepository(
        _ThrowingLevelBox(),
        mapper,
      );

      final result = await repo.getLevelDefinition(1);

      expect(result, isA<Error<Level>>());
    });
  });
}
