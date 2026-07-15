import 'package:arrowconmango_front/features/player/data/guest_name_generator.dart';
import 'package:arrowconmango_front/features/player/data/player_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/player_test_setup.dart';

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
  });
}
