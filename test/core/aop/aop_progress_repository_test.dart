import 'package:arrowconmango_front/core/aop/aop_progress_repository.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_progress_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class _MockProgressRepository extends Mock implements IProgressRepository {}

class _AppProgressFake extends Fake implements AppProgress {}

void main() {
  setUpAll(() {
    registerFallbackValue(_AppProgressFake());
  });

  group('AopProgressRepository', () {
    late _MockProgressRepository delegate;
    late AopProgressRepository repository;

    setUp(() {
      delegate = _MockProgressRepository();
      repository = AopProgressRepository(delegate);
    });

    test('loadProgress forwards delegate result', () async {
      final expected = Success<AppProgress>(AppProgress());
      when(delegate.loadProgress).thenAnswer((_) async => expected);

      final result = await repository.loadProgress();

      expect(result, equals(expected));
      verify(delegate.loadProgress).called(1);
    });

    test('loadProgress maps infrastructure exception to GenericFailure', () async {
      when(delegate.loadProgress).thenThrow(HiveError('disk full'));

      final result = await repository.loadProgress();

      expect(result, isA<Error<AppProgress>>());
      expect(
        (result as Error<AppProgress>).failure,
        isA<GenericFailure>().having((f) => f.message, 'message', contains('disk full')),
      );
    });

    test('saveProgress forwards delegate result', () async {
      const expected = Success<void>(null);
      when(() => delegate.saveProgress(any())).thenAnswer((_) async => expected);

      final progress = AppProgress(unlockedLevels: [1]);
      final result = await repository.saveProgress(progress);

      expect(result, equals(expected));
      verify(() => delegate.saveProgress(progress)).called(1);
    });

    test('saveProgress maps infrastructure exception to GenericFailure', () async {
      when(() => delegate.saveProgress(any())).thenThrow(HiveError('disk full'));

      final progress = AppProgress();
      final result = await repository.saveProgress(progress);

      expect(result, isA<Error<void>>());
    });
  });
}
