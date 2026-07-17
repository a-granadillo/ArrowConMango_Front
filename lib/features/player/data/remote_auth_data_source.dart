import 'package:dio/dio.dart';

import '../../../core/config/api_config.dart';

/// Talks to the backend's `POST /auth/register` and `POST /auth/login`.
///
/// Uses its own bare [Dio] (no [AuthInterceptor]) for the same reason the
/// interceptor's internal guest-login client does: registering/logging in
/// must never trigger an automatic guest login first, and the response here
/// carries the real token — nothing to attach until we have it.
class RemoteAuthDataSource {
  RemoteAuthDataSource()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: ApiConfig.connectTimeout,
            receiveTimeout: ApiConfig.receiveTimeout,
          ),
        );

  final Dio _dio;

  /// Registers a new account. The backend logs the caller in as part of
  /// registration, so the response already carries a token.
  Future<AuthResult> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'email': email, 'password': password, 'username': username},
    );
    final data = response.data!;
    return AuthResult(
      token: data['token'] as String,
      username: data['username'] as String,
    );
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return response.data!['token'] as String;
  }
}

/// Outcome of a successful [RemoteAuthDataSource.register] call.
class AuthResult {
  const AuthResult({required this.token, required this.username});

  final String token;
  final String username;
}
