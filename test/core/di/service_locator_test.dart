import 'dart:io';

import 'package:arrowconmango_front/core/audio/audio_settings_local_data_source.dart';
import 'package:arrowconmango_front/core/database/hive_config.dart';
import 'package:arrowconmango_front/core/di/service_locator.dart';
import 'package:arrowconmango_front/features/game/data/models/app_progress_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_level_repository.dart';
import 'package:arrowconmango_front/features/player/data/player_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late final Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('acm_di_test');
    Hive.init(tempDir.path);
    HiveConfig.registerAdapters();
    await Hive.openBox<LevelModel>(HiveConfig.levelsBoxName);
    await Hive.openBox<AppProgressModel>(HiveConfig.progressBoxName);
    await Hive.openBox<dynamic>(PlayerLocalDataSource.boxName);
    await Hive.openBox<dynamic>(AudioSettingsLocalDataSource.boxName);
  });

  test('setupServiceLocator inicializa sin errores', () async {
    await setupServiceLocator();
    expect(sl.isRegistered<ILevelRepository>(), isTrue);
  });

  tearDownAll(() async {
    await sl.reset();
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });
}
