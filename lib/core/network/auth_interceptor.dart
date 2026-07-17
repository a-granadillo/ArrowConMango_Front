// ignore_for_file: prefer_initializing_formals
// Named params are assigned to private fields so the public API stays clean.

import 'package:dio/dio.dart';

import '../../features/player/data/auth_token_store.dart';
import '../config/api_config.dart';

/// Attaches a `Bearer` JWT to every request, obtaining one via guest login
/// on first use and re-authenticating once if the backend rejects it.
///
/// Uses a plain [Dio] instance (no interceptors) for the guest-login call
/// itself, so authentication never recurses into this interceptor.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required AuthTokenStore tokenStore,
    required String guestUuid,
    required String guestDisplayName,
  })  : _tokenStore = tokenStore,
        _guestUuid = guestUuid,
        _guestDisplayName = guestDisplayName,
        _authDio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: ApiConfig.connectTimeout,
            receiveTimeout: ApiConfig.receiveTimeout,
          ),
        );

  final AuthTokenStore _tokenStore;
  final String _guestUuid;
  final String _guestDisplayName;
  final Dio _authDio;

  Future<String> _guestLogin() async {
    // displayName is honored by the backend only when this UUID doesn't
    // resolve to an existing user yet (find-or-create); renaming an
    // already-known guest goes through PATCH /player/me (PlayerCubit.rename),
    // not through this call.
    final response = await _authDio.post<Map<String, dynamic>>(
      '/auth/guest',
      data: {'uuid': _guestUuid, 'displayName': _guestDisplayName},
    );
    final token = response.data!['token'] as String;
    await _tokenStore.save(token);
    return token;
  }

  Future<String> _ensureToken() async {
    final existing = _tokenStore.token;
    if (existing != null) return existing;
    return _guestLogin();
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    _ensureToken().then((token) {
      options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    }).catchError((Object error) {
      handler.reject(DioException(requestOptions: options, error: error));
    });
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    _tokenStore.clear().then((_) => _guestLogin()).then((token) {
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $token';
      _authDio.fetch<dynamic>(retryOptions).then(
            handler.resolve,
            onError: (_) => handler.next(err),
          );
    }).catchError((Object _) {
      handler.next(err);
    });
  }
}
