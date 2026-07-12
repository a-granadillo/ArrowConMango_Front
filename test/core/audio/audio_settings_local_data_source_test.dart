import 'dart:io';

import 'package:arrowconmango_front/core/audio/audio_settings_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('AudioSettingsLocalDataSource', () {
    late Directory dir;
    late Box<dynamic> box;
    late AudioSettingsLocalDataSource dataSource;

    setUp(() async {
      // Arrange
      dir = Directory.systemTemp.createTempSync('acm_audio');
      Hive.init(dir.path);
      box = await Hive.openBox<dynamic>('audio_settings_test');
      dataSource = AudioSettingsLocalDataSource(box: box);
    });

    tearDown(() async {
      await box.close();
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    });

    test('when opening the box, it should return default value false', () {
      // Act
      final result = dataSource.isMuted;

      // Assert
      expect(result, isFalse);
    });

    test(
      'when setMuted is called with true, it should persist the value',
      () async {
        // Arrange
        const muted = true;

        // Act
        await dataSource.setMuted(muted);
        final result = dataSource.isMuted;

        // Assert
        expect(result, isTrue);
      },
    );
  });
}
