import 'audio_track.dart';
import 'sfx_clip.dart';

/// Port for playing background music and one-shot sound effects.
///
/// Implementations are expected to be resilient: audio operations must never
/// crash the application, even when assets are missing or the platform
/// rejects a playback request.
abstract interface class AudioService {
  /// Starts looping the requested background music track.
  ///
  /// If the service is muted the call is a no-op. Playing the same track that
  /// is already running is also a no-op to avoid restarting the loop.
  Future<void> playBgm(AudioTrack track);

  /// Stops the currently playing background music, if any.
  Future<void> stopBgm();

  /// Plays a one-shot sound effect.
  ///
  /// If the service is muted the call is a no-op.
  Future<void> playSfx(SfxClip clip);

  /// Mutes all audio output and persists the preference.
  Future<void> mute();

  /// Unmutes all audio output and persists the preference.
  Future<void> unmute();

  /// Whether audio is currently muted.
  bool get isMuted;

  /// Releases all native audio resources.
  Future<void> dispose();
}
