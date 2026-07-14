import 'package:flutter_bloc/flutter_bloc.dart';

import 'audio_service.dart';
import 'audio_settings_state.dart';

/// Cubit that exposes the global audio mute toggle.
///
/// State is binary (muted/unmuted), so a [Cubit] is sufficient.
class AudioSettingsCubit extends Cubit<AudioSettingsState> {
  AudioSettingsCubit({required AudioService service})
    : _service = service,
      super(AudioSettingsState(isMuted: service.isMuted));

  final AudioService _service;

  /// Toggles the global mute state and persists the preference.
  Future<void> toggleMute() async {
    if (state.isMuted) {
      await _service.unmute();
    } else {
      await _service.mute();
    }
    emit(AudioSettingsState(isMuted: _service.isMuted));
  }
}
