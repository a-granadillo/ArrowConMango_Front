// ignore_for_file: prefer_initializing_formals
// Named params are assigned to private fields so the public API stays clean.

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'audio_service.dart';
import 'audio_settings_local_data_source.dart';
import 'audio_track.dart';
import 'sfx_clip.dart';

Future<void> disposeAudioService(AudioService service) => service.dispose();

/// Concrete [AudioService] implementation powered by the `audioplayers` package.
///
/// Background music loops indefinitely and sound effects are pre-cached in a
/// small pool so they can be fired with minimal latency. Every operation is
/// guarded by a try/catch block: audio must never crash the app, even if the
/// underlying asset is missing or the platform player fails.
@LazySingleton(as: AudioService, dispose: disposeAudioService)
class AudioServiceImpl implements AudioService {
  AudioServiceImpl({required AudioSettingsLocalDataSource settings})
    : _settings = settings,
      _muted = settings.isMuted {
    _configureBgmPlayer();
    _precache();
  }

  final AudioSettingsLocalDataSource _settings;
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final Map<SfxClip, AudioPlayer> _sfxPool = {};
  bool _muted;
  AudioTrack? _currentTrack;
  int _bgmGeneration = 0;

  @override
  bool get isMuted => _muted;

  @override
  Future<void> playBgm(AudioTrack track) async {
    if (_muted) return;

    final gen = ++_bgmGeneration;

    try {
      if (_currentTrack == track) {
        if (_bgmPlayer.state == PlayerState.playing) return;
      }

      await _bgmPlayer.stop();
      if (gen != _bgmGeneration) return;

      _currentTrack = track;
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      if (gen != _bgmGeneration) return;

      await _bgmPlayer.play(AssetSource(track.assetPath));
    } catch (e, stackTrace) {
      debugPrint('AudioServiceImpl.playBgm failed: $e\n$stackTrace');
    }
  }

  @override
  Future<void> stopBgm() async {
    try {
      final track = _currentTrack;
      await _bgmPlayer.stop();
      if (_currentTrack == track) {
        _currentTrack = null;
      }
    } catch (e, stackTrace) {
      debugPrint('AudioServiceImpl.stopBgm failed: $e\n$stackTrace');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _bgmPlayer.pause();
    } catch (e, stackTrace) {
      debugPrint('AudioServiceImpl.pause failed: $e\n$stackTrace');
    }
  }

  @override
  Future<void> resume() async {
    if (_muted || _currentTrack == null) return;
    try {
      await _bgmPlayer.resume();
    } catch (e, stackTrace) {
      debugPrint('AudioServiceImpl.resume failed: $e\n$stackTrace');
    }
  }

  @override
  Future<void> playSfx(SfxClip clip) async {
    if (_muted) return;

    try {
      final player = _sfxPool[clip];
      if (player == null) return;

      await player.stop();
      await player.play(AssetSource(clip.assetPath));
    } catch (e, stackTrace) {
      debugPrint('AudioServiceImpl.playSfx failed: $e\n$stackTrace');
    }
  }

  @override
  Future<void> mute() async {
    _muted = true;
    await _setVolumeOnAllPlayers(0.0);
    await _persistMuted(true);
  }

  @override
  Future<void> unmute() async {
    _muted = false;
    await _setVolumeOnAllPlayers(1.0);
    await _persistMuted(false);
  }

  @override
  Future<void> dispose() async {
    try {
      for (final player in _sfxPool.values) {
        await player.release();
      }
      _sfxPool.clear();
      await _bgmPlayer.release();
    } catch (e, stackTrace) {
      debugPrint('AudioServiceImpl.dispose failed: $e\n$stackTrace');
    }
  }

  /// Configures the BGM player to request audio focus so it keeps priority
  /// over short sound effects on Android.
  Future<void> _configureBgmPlayer() async {
    try {
      await _bgmPlayer.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          audioFocus: AndroidAudioFocus.gain,
        ),
      ));
    } catch (e, stackTrace) {
      debugPrint(
        'AudioServiceImpl._configureBgmPlayer failed: $e\n$stackTrace',
      );
    }
  }

  /// Pre-loads every [SfxClip] into its own [AudioPlayer] so effects are ready
  /// to play immediately.
  Future<void> _precache() async {
    for (final clip in SfxClip.values) {
      try {
        final player = AudioPlayer();
        await player.setAudioContext(AudioContext(
          android: const AudioContextAndroid(
            audioFocus: AndroidAudioFocus.none,
          ),
        ));
        await player.setSource(AssetSource(clip.assetPath));
        _sfxPool[clip] = player;
      } catch (e, stackTrace) {
        debugPrint(
          'AudioServiceImpl._precache failed for $clip: $e\n$stackTrace',
        );
      }
    }
  }

  Future<void> _setVolumeOnAllPlayers(double volume) async {
    try {
      await _bgmPlayer.setVolume(volume);
      for (final player in _sfxPool.values) {
        await player.setVolume(volume);
      }
    } catch (e, stackTrace) {
      debugPrint(
        'AudioServiceImpl._setVolumeOnAllPlayers failed: $e\n$stackTrace',
      );
    }
  }

  Future<void> _persistMuted(bool value) async {
    try {
      await _settings.setMuted(value);
    } catch (e, stackTrace) {
      debugPrint('AudioServiceImpl._persistMuted failed: $e\n$stackTrace');
    }
  }
}
