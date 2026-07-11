import 'package:equatable/equatable.dart';

/// A local, anonymous player identity (Guest-First).
///
/// The player is created automatically on first launch with a random [uuid]
/// and a fun [displayName] (e.g. `MangoLoco_99`). No sign-up required; social
/// login to link the account is a future, optional step.
class GuestPlayer extends Equatable {
  /// Stable anonymous identifier (UUID v4).
  final String uuid;

  /// Public, editable display name shown in menus and the leaderboard.
  final String displayName;

  const GuestPlayer({
    required this.uuid,
    required this.displayName,
  });

  /// Returns a copy with an updated [displayName].
  GuestPlayer copyWith({String? displayName}) {
    return GuestPlayer(
      uuid: uuid,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  List<Object?> get props => [uuid, displayName];
}
