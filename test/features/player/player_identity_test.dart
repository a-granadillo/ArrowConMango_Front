import 'package:arrowconmango_front/features/player/data/guest_name_generator.dart';
import 'package:arrowconmango_front/features/player/data/player_local_data_source.dart';
import 'package:arrowconmango_front/features/player/data/remote_player_data_source.dart';
import 'package:arrowconmango_front/features/player/domain/guest_player.dart';
import 'package:arrowconmango_front/features/player/presentation/player_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes/fake_player_repository.dart';
import '../../helpers/player_test_setup.dart';

class _MockRemotePlayerDataSource extends Mock
    implements RemotePlayerDataSource {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlayerLocalDataSource', () {
    test('should_create_and_persist_guest_when_box_is_empty', () async {
      // Arrange
      final ctx = await makePlayerContext();
      final dataSource = PlayerLocalDataSource(
        box: ctx.box,
        nameGenerator: GuestNameGenerator(),
      );
      await ctx.box.clear();

      // Act
      final created = dataSource.getOrCreate();
      final reloaded = dataSource.getOrCreate();

      // Assert: identity is stable across reads (persisted).
      expect(created.uuid, isNotEmpty);
      expect(created.displayName, isNotEmpty);
      expect(reloaded.uuid, created.uuid);
      expect(reloaded.displayName, created.displayName);

      await ctx.dispose();
    });
  });

  group('PlayerCubit', () {
    test('should_update_and_persist_name_when_renamed', () async {
      // Arrange
      final ctx = await makePlayerContext(name: 'MangoLoco_10');

      // Act
      await ctx.cubit.rename('Abraham');

      // Assert: state updated and value persisted to the box.
      expect(ctx.cubit.state.displayName, 'Abraham');
      final persisted = ctx.dataSource.getOrCreate();
      expect(persisted.displayName, 'Abraham');

      await ctx.dispose();
    });

    test('should_ignore_blank_rename', () async {
      // Arrange
      final ctx = await makePlayerContext(name: 'MangoLoco_10');

      // Act
      await ctx.cubit.rename('   ');

      // Assert
      expect(ctx.cubit.state.displayName, 'MangoLoco_10');

      await ctx.dispose();
    });

    test('should_sync_the_new_name_to_the_backend_when_renamed', () async {
      // Arrange
      final player = GuestPlayer(uuid: 'uuid-remote', displayName: 'Old');
      final remote = _MockRemotePlayerDataSource();
      when(() => remote.updateDisplayName(any()))
          .thenAnswer((_) async {});
      final cubit = PlayerCubit(
        dataSource: FakePlayerRepository(player),
        initial: player,
        remoteDataSource: remote,
      );

      // Act
      await cubit.rename('NewRemoteName');
      await Future<void>.delayed(Duration.zero); // let the fire-and-forget run

      // Assert
      verify(() => remote.updateDisplayName('NewRemoteName')).called(1);
      await cubit.close();
    });

    test('should_keep_the_local_rename_when_the_remote_sync_fails', () async {
      // Arrange
      final player = GuestPlayer(uuid: 'uuid-remote-2', displayName: 'Old');
      final remote = _MockRemotePlayerDataSource();
      when(() => remote.updateDisplayName(any()))
          .thenThrow(Exception('offline'));
      final cubit = PlayerCubit(
        dataSource: FakePlayerRepository(player),
        initial: player,
        remoteDataSource: remote,
      );

      // Act
      await cubit.rename('StillRenamedLocally');
      await Future<void>.delayed(Duration.zero);

      // Assert — local rename succeeded despite the remote failure.
      expect(cubit.state.displayName, 'StillRenamedLocally');
      await cubit.close();
    });
  });
}
