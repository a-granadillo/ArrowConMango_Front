import 'package:arrowconmango_front/core/aop/aop_player_repository.dart';
import 'package:arrowconmango_front/features/player/domain/guest_player.dart';
import 'package:arrowconmango_front/features/player/domain/i_player_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPlayerRepository extends Mock implements IPlayerRepository {}

void main() {
  group('AopPlayerRepository', () {
    late _MockPlayerRepository delegate;
    late AopPlayerRepository repository;

    setUp(() {
      delegate = _MockPlayerRepository();
      repository = AopPlayerRepository(delegate);
    });

    test('getOrCreate forwards delegate result', () {
      final player = GuestPlayer(uuid: 'u1', displayName: 'Mango');
      when(delegate.getOrCreate).thenReturn(player);

      final result = repository.getOrCreate();

      expect(result, equals(player));
      verify(delegate.getOrCreate).called(1);
    });

    test('getOrCreate rethrows exceptions after logging', () {
      when(delegate.getOrCreate).thenThrow(Exception('hive failed'));

      expect(
        repository.getOrCreate,
        throwsA(isA<Exception>()),
      );
    });

    test('saveDisplayName forwards delegate result', () async {
      when(() => delegate.saveDisplayName(any())).thenAnswer((_) async {});

      await repository.saveDisplayName('NewName');

      verify(() => delegate.saveDisplayName('NewName')).called(1);
    });

    test('saveDisplayName rethrows exceptions after logging', () async {
      when(() => delegate.saveDisplayName(any())).thenThrow(Exception('hive failed'));

      expect(
        () => repository.saveDisplayName('NewName'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
