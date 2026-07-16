import 'package:arrowconmango_front/core/aop/aop_level_repository.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_level_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class _MockLevelRepository extends Mock implements ILevelRepository {}

void main() {
  group('AopLevelRepository', () {
    late _MockLevelRepository delegate;
    late AopLevelRepository repository;

    setUp(() {
      delegate = _MockLevelRepository();
      repository = AopLevelRepository(delegate);
    });

    test('loadLevel forwards delegate result', () async {
      final session = GameSession(
        sessionId: 'test',
        boardState: BoardState(arrows: const []),
        startedAtMs: 0,
      );
      final expected = Success<GameSession>(session);
      when(() => delegate.loadLevel(1)).thenAnswer((_) async => expected);

      final result = await repository.loadLevel(1);

      expect(result, equals(expected));
    });

    test('loadLevel catches exception and returns GenericFailure', () async {
      when(() => delegate.loadLevel(1)).thenThrow(HiveError('corrupt'));

      final result = await repository.loadLevel(1);

      expect(result, isA<Error<GameSession>>());
      expect(
        (result as Error<GameSession>).failure,
        isA<GenericFailure>(),
      );
    });

    test('getLevelCount forwards delegate result', () async {
      const expected = Success<int>(15);
      when(delegate.getLevelCount).thenAnswer((_) async => expected);

      final result = await repository.getLevelCount();

      expect(result, equals(expected));
    });

    test('getLevelDefinition catches exception and returns GenericFailure', () async {
      when(() => delegate.getLevelDefinition(1)).thenThrow(HiveError('corrupt'));

      final result = await repository.getLevelDefinition(1);

      expect(result, isA<Error<Level>>());
      expect(
        (result as Error<Level>).failure,
        isA<GenericFailure>().having((f) => f.message, 'message', contains('corrupt')),
      );
    });
  });
}
