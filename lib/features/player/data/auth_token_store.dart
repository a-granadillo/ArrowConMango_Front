// ignore_for_file: prefer_initializing_formals
// Named params are assigned to private fields so the public API stays clean.

import 'package:hive/hive.dart';

/// Persists the backend JWT obtained from guest login.
///
/// Reuses the same Hive box as [PlayerLocalDataSource] (`'player'`), storing
/// the token as a plain string alongside the guest identity.
class AuthTokenStore {
  AuthTokenStore({required Box<dynamic> box}) : _box = box;

  static const String _tokenKey = 'apiToken';

  final Box<dynamic> _box;

  String? get token => _box.get(_tokenKey) as String?;

  Future<void> save(String token) => _box.put(_tokenKey, token);

  Future<void> clear() => _box.delete(_tokenKey);
}
