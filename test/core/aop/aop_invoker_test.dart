import 'package:arrowconmango_front/core/aop/aop_invoker.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_progress_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProgressRepository extends Mock implements IProgressRepository {}

void main() {
  group('AopInvoker.invokeResult', () {
    late _MockProgressRepository delegate;

    setUp(() {
      delegate = _MockProgressRepository();
    });

    test('returns delegate result on success', () async {
      final expected = Success<AppProgress>(AppProgress());
      when(delegate.loadProgress).thenAnswer((_) async => expected);

      final result = await AopInvoker.invokeResult(
        'IProgressRepository',
        'loadProgress',
        delegate.loadProgress,
      );

      expect(result, equals(expected));
    });

    test('converts infrastructure exception to GenericFailure Error', () async {
      when(delegate.loadProgress).thenThrow(Exception('boom'));

      final result = await AopInvoker.invokeResult(
        'IProgressRepository',
        'loadProgress',
        delegate.loadProgress,
      );

      expect(result, isA<Error<AppProgress>>());
      final failure = (result as Error<AppProgress>).failure;
      expect(failure, isA<GenericFailure>());
      expect(failure.message, contains('boom'));
    });
  });

  group('AopInvoker.invoke', () {
    late _MockRepository delegate;

    setUp(() {
      delegate = _MockRepositoryImpl();
    });

    test('returns delegate result on success', () async {
      when(delegate.go).thenAnswer((_) async => 42);

      final result = await AopInvoker.invoke(
        'IMockRepository',
        'go',
        delegate.go,
      );

      expect(result, equals(42));
    });

    test('rethrows non-Result exceptions after logging', () async {
      when(delegate.go).thenThrow(Exception('boom'));

      expect(
        () => AopInvoker.invoke('IMockRepository', 'go', delegate.go),
        throwsA(isA<Exception>()),
      );
    });
  });
}

abstract class _MockRepository {
  Future<int> go();
}

class _MockRepositoryImpl extends Mock implements _MockRepository {}
