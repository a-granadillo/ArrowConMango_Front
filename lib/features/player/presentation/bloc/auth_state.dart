import 'package:equatable/equatable.dart';

/// {@template auth_state}
/// Base class for all states emitted by [AuthCubit].
/// {@endtemplate}
sealed class AuthState extends Equatable {
  /// {@macro auth_state}
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Nothing has happened yet — the auth gate/forms are idle.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// A register/login request is in flight.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// The player continued as an anonymous guest.
final class AuthGuest extends AuthState {
  const AuthGuest();
}

/// The player registered or logged in with an account.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({this.progressMigrated = false});

  /// Whether the local guest progress has finished uploading to this
  /// account (see [AuthCubit]'s post-login progress migration).
  final bool progressMigrated;

  @override
  List<Object?> get props => [progressMigrated];
}

/// The last register/login attempt failed.
final class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
