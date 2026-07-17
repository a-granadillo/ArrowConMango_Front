// ignore_for_file: prefer_initializing_formals
// Named params are assigned to private fields so the public API stays clean.

import 'package:dio/dio.dart';

import '../../features/player/data/session_store.dart';
import '../config/api_config.dart';

/// Attaches a `Bearer` JWT to every request, obtaining one via guest login
/// on first use and re-authenticating once if the backend rejects it.
///
/// Uses a plain [Dio] instance (no interceptors) for the guest-login call
/// itself, so authentication never recurses into this interceptor.
///
/// The retry-on-401 behavior depends on [SessionStore.mode]: a [guest]
/// session is silently re-logged-in (the identity is anonymous anyway), but
/// an [authenticated] session is signed out instead of being downgraded to
/// guest — degrading a logged-in player to an anonymous identity behind
/// their back would be a silent account switch, not a retry.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SessionStore sessionStore,
    required String guestUuid,
    required String guestDisplayName,
  })  : _sessionStore = sessionStore,
        _guestUuid = guestUuid,
        _guestDisplayName = guestDisplayName,
        _authDio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: ApiConfig.connectTimeout,
            receiveTimeout: ApiConfig.receiveTimeout,
          ),
        );

  final SessionStore _sessionStore;
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
    await _sessionStore.startGuest(token);
    return token;
  }

  Future<String> _ensureToken() async {
    final existing = _sessionStore.token;
    if (existing != null) return existing;

    if (_sessionStore.mode == SessionMode.authenticated) {
      // A logged-in session should always carry a token; if it doesn't,
      // fail loudly rather than silently falling back to a guest login.
      throw StateError('Authenticated session is missing its token');
    }

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

    if (_sessionStore.mode == SessionMode.authenticated) {
      // Sign out and propagate the error — SessionStore's ChangeNotifier
      // lets the router redirect to the auth gate. Never retry as guest.
      _sessionStore.signOut().then((_) => handler.next(err));
      return;
    }

    _sessionStore.signOut().then((_) => _guestLogin()).then((token) {
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
