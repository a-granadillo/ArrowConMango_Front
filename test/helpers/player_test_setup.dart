import 'dart:io';

import 'package:arrowconmango_front/features/player/data/guest_name_generator.dart';
import 'package:arrowconmango_front/features/player/data/player_local_data_source.dart';
import 'package:arrowconmango_front/features/player/domain/guest_player.dart';
import 'package:arrowconmango_front/features/player/presentation/player_cubit.dart';
import 'package:hive/hive.dart';

import 'fakes/fake_player_repository.dart';

/// Builds a synchronous [PlayerCubit] backed by an in-memory fake (no Hive).
///
/// Use in widget tests to avoid real async I/O inside `testWidgets`.
PlayerCubit makePlayerCubit({
  String name = 'MangoTest_01',
  String uuid = 'uuid-test-1',
}) {
  final player = GuestPlayer(uuid: uuid, displayName: name);
  return PlayerCubit(dataSource: FakePlayerRepository(player), initial: player);
}

/// Bundles a real (temp-Hive backed) player stack for tests.
class PlayerTestContext {
  PlayerTestContext(this.cubit, this.dataSource, this.box, this._dir);

  final PlayerCubit cubit;
  final PlayerLocalDataSource dataSource;
  final Box<dynamic> box;
  final Directory _dir;

  Future<void> dispose() async {
    await cubit.close();
    await box.close();
    try {
      _dir.deleteSync(recursive: true);
    } catch (_) {}
  }
}

int _boxCounter = 0;

/// Creates an isolated [PlayerCubit] backed by a fresh temporary Hive box.
Future<PlayerTestContext> makePlayerContext({
  String name = 'MangoTest_01',
  String uuid = 'uuid-test-1',
}) async {
  final dir = Directory.systemTemp.createTempSync('acm_player');
  Hive.init(dir.path);
  final box = await Hive.openBox<dynamic>('player_${_boxCounter++}');
  final dataSource = PlayerLocalDataSource(
    box: box,
    nameGenerator: GuestNameGenerator(),
  );
  final cubit = PlayerCubit(
    dataSource: dataSource,
    initial: GuestPlayer(uuid: uuid, displayName: name),
  );
  return PlayerTestContext(cubit, dataSource, box, dir);
}
