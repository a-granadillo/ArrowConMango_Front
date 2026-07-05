import 'package:arrowconmango_front/features/game/data/models/app_progress_model.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/app_progress_mapper.dart';
import 'package:arrowconmango_front/features/game/data/repositories/hive_progress_repository.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:hive/hive.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';

class _FakeProgressBox extends Fake implements Box<AppProgressModel> {
  final Map<dynamic, AppProgressModel> _data = {};

  void seed(String key, AppProgressModel model) {
    _data[key] = model;
  }

  @override
  AppProgressModel? get(dynamic key, {AppProgressModel? defaultValue}) {
    return _data.containsKey(key) ? _data[key] : defaultValue;
  }

  @override
  Future<void> put(dynamic key, AppProgressModel value) async {
    _data[key] = value;
  }

  @override
  bool containsKey(dynamic key) => _data.containsKey(key);

  @override
  Iterable<AppProgressModel> get values => _data.values;
}

class _ThrowingProgressBox extends Fake implements Box<AppProgressModel> {
  @override
  AppProgressModel? get(dynamic key, {AppProgressModel? defaultValue}) {
    throw Exception('Box read error');
  }

  @override
  Future<void> put(dynamic key, AppProgressModel value) async {
    throw Exception('Box write error');
  }
}

void main() {
  const mapper = AppProgressMapper();

  group('HiveProgressRepository', () {
    test('loadProgress returns default AppProgress when nothing is saved',
        () async {
      final box = _FakeProgressBox();
      final repo = HiveProgressRepository(box, mapper);

      final result = await repo.loadProgress();

      expect(result, isA<Success<AppProgress>>());
      final progress = (result as Success<AppProgress>).value;
      expect(progress.unlockedLevels, isEmpty);
      expect(progress.currentToken, isEmpty);
    });

    test('loadProgress returns mapped entity when progress exists', () async {
      final box = _FakeProgressBox()
        ..seed(
          'app_progress',
          const AppProgressModel(
            currentLevel: 3,
            completedLevels: [1, 2],
          ),
        );
      final repo = HiveProgressRepository(box, mapper);

      final result = await repo.loadProgress();

      expect(result, isA<Success<AppProgress>>());
      final progress = (result as Success<AppProgress>).value;
      expect(progress.unlockedLevels, equals([1, 2]));
      expect(progress.currentToken, equals('3'));
    });

    test('saveProgress stores mapped model', () async {
      final box = _FakeProgressBox();
      final repo = HiveProgressRepository(box, mapper);
      const progress = AppProgress(
        unlockedLevels: [1, 2, 3],
        currentToken: '4',
      );

      final result = await repo.saveProgress(progress);

      expect(result, isA<Success<void>>());
      final saved = box.get('app_progress');
      expect(saved, isNotNull);
      expect(saved!.currentLevel, equals(4));
      expect(saved.completedLevels, equals([1, 2, 3]));
    });

    test('loadProgress wraps exceptions in Error', () async {
      final repo = HiveProgressRepository(_ThrowingProgressBox(), mapper);

      final result = await repo.loadProgress();

      expect(result, isA<Error<AppProgress>>());
      expect((result as Error<AppProgress>).failure, isA<GenericFailure>());
    });

    test('saveProgress wraps exceptions in Error', () async {
      final repo = HiveProgressRepository(_ThrowingProgressBox(), mapper);

      final result = await repo.saveProgress(const AppProgress());

      expect(result, isA<Error<void>>());
      expect((result as Error<void>).failure, isA<GenericFailure>());
    });
  });
}
