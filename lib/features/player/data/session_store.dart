// ignore_for_file: prefer_initializing_formals
// Named params are assigned to private fields so the public API stays clean.

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'auth_token_store.dart';

/// Distinguishes how the current player's identity was established.
enum SessionMode {
  /// No identity yet — the app should show the auth gate.
  none,

  /// Playing as an anonymous, auto-created guest.
  guest,

  /// Logged in with a registered email/password account.
  authenticated,
}

/// Tracks whether the player is a guest or a logged-in account, on top of
/// the JWT already held by [AuthTokenStore].
///
/// A [ChangeNotifier] so the router can redirect to the auth gate the moment
/// the mode changes to [SessionMode.none] — e.g. after [signOut] or after
/// [AuthInterceptor] force-logs-out an authenticated session whose token
/// expired (see `auth_interceptor.dart`).
class SessionStore extends ChangeNotifier {
  SessionStore({required Box<dynamic> box, required AuthTokenStore tokenStore})
      : _box = box,
        _tokenStore = tokenStore;

  static const String _modeKey = 'sessionMode';

  final Box<dynamic> _box;
  final AuthTokenStore _tokenStore;

  SessionMode get mode {
    final raw = _box.get(_modeKey) as String?;
    return SessionMode.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => SessionMode.none,
    );
  }

  String? get token => _tokenStore.token;

  Future<void> startGuest(String token) async {
    await _tokenStore.save(token);
    await _box.put(_modeKey, SessionMode.guest.name);
    notifyListeners();
  }

  Future<void> startAuthenticated(String token) async {
    await _tokenStore.save(token);
    await _box.put(_modeKey, SessionMode.authenticated.name);
    notifyListeners();
  }

  /// Clears the token and mode, sending the player back to [SessionMode.none].
  Future<void> signOut() async {
    await _tokenStore.clear();
    await _box.put(_modeKey, SessionMode.none.name);
    notifyListeners();
  }
}
