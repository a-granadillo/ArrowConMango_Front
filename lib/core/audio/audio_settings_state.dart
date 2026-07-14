import 'package:equatable/equatable.dart';

/// State of the global audio mute toggle.
final class AudioSettingsState extends Equatable {
  const AudioSettingsState({required this.isMuted});

  /// `true` when all audio output is muted.
  final bool isMuted;

  @override
  List<Object?> get props => [isMuted];
}
