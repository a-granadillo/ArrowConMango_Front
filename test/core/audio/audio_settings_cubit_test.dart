import 'package:arrowconmango_front/core/audio/audio_settings_cubit.dart';
import 'package:arrowconmango_front/core/audio/audio_settings_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes/fake_audio_service.dart';

void main() {
  group('AudioSettingsCubit', () {
    late FakeAudioService fakeAudioService;

    setUp(() {
      fakeAudioService = FakeAudioService();
    });

    blocTest<AudioSettingsCubit, AudioSettingsState>(
      'when toggleMute is called from unmuted state, emits [isMuted: true]',
      build: () => AudioSettingsCubit(service: fakeAudioService),
      act: (cubit) => cubit.toggleMute(),
      expect: () => [const AudioSettingsState(isMuted: true)],
      verify: (_) => expect(fakeAudioService.muteCalls, 1),
    );

    blocTest<AudioSettingsCubit, AudioSettingsState>(
      'when toggleMute is called twice, emits [isMuted: false]',
      build: () => AudioSettingsCubit(service: fakeAudioService),
      act: (cubit) async {
        await cubit.toggleMute();
        await cubit.toggleMute();
      },
      expect: () => [
        const AudioSettingsState(isMuted: true),
        const AudioSettingsState(isMuted: false),
      ],
      verify: (_) {
        expect(fakeAudioService.muteCalls, 1);
        expect(fakeAudioService.unmuteCalls, 1);
      },
    );
  });
}
