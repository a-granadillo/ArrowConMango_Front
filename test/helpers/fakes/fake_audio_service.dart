import 'package:arrowconmango_front/core/audio/audio_service.dart';
import 'package:arrowconmango_front/core/audio/audio_track.dart';
import 'package:arrowconmango_front/core/audio/sfx_clip.dart';

/// Manual fake for [AudioService] shared across audio-related tests.
///
/// Records every BGM/SFX call and mute/unmute invocation so tests can verify
/// side effects without touching real platform audio.
class FakeAudioService implements AudioService {
  final List<AudioTrack> bgmCalls = [];
  final List<SfxClip> sfxCalls = [];
  int stopBgmCalls = 0;
  int pauseCalls = 0;
  int resumeCalls = 0;
  int muteCalls = 0;
  int unmuteCalls = 0;
  bool _muted = false;

  @override
  Future<void> playBgm(AudioTrack track) async => bgmCalls.add(track);

  @override
  Future<void> stopBgm() async => stopBgmCalls++;

  @override
  Future<void> pause() async => pauseCalls++;

  @override
  Future<void> resume() async => resumeCalls++;

  @override
  Future<void> playSfx(SfxClip clip) async => sfxCalls.add(clip);

  @override
  Future<void> mute() async {
    _muted = true;
    muteCalls++;
  }

  @override
  Future<void> unmute() async {
    _muted = false;
    unmuteCalls++;
  }

  @override
  bool get isMuted => _muted;

  @override
  Future<void> dispose() async {}
}
