import 'dart:async';
import 'dart:io';

import 'package:arrowconmango_front/core/network/auth_interceptor.dart';
import 'package:arrowconmango_front/features/player/data/auth_token_store.dart';
import 'package:arrowconmango_front/features/player/data/session_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late Box<dynamic> box;
  late SessionStore sessionStore;
  int boxCounter = 0;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('acm_auth_interceptor');
    Hive.init(dir.path);
    box = await Hive.openBox<dynamic>('auth_interceptor_${boxCounter++}');
    sessionStore = SessionStore(box: box, tokenStore: AuthTokenStore(box: box));
  });

  tearDown(() async {
    await box.close();
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  DioException unauthorizedError() {
    final requestOptions = RequestOptions(path: '/progress');
    return DioException(
      requestOptions: requestOptions,
      response: Response(requestOptions: requestOptions, statusCode: 401),
    );
  }

  // Swallows the handler's completer error so the test doesn't flag it as
  // an unhandled zone exception — in production, Dio's own machinery awaits
  // this future to advance the interceptor chain; nothing does that here.
  Future<void> drain(dynamic handler) async {
    try {
      // ignore: invalid_use_of_protected_member
      await handler.future;
    } catch (_) {
      // Expected: production code never awaits this future either.
    }
  }

  group('onError (401)', () {
    test(
      'should_sign_out_without_falling_back_to_guest_when_an_authenticated_session_expires',
      () async {
        // Arrange — a logged-in session with a (now-expired) token.
        await sessionStore.startAuthenticated('expired-account-token');
        final interceptor = AuthInterceptor(
          sessionStore: sessionStore,
          guestUuid: 'irrelevant-uuid',
          guestDisplayName: 'irrelevant',
        );
        final handler = ErrorInterceptorHandler();
        unawaited(drain(handler));

        // Act
        interceptor.onError(unauthorizedError(), handler);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert — signed out to `none`, NOT silently downgraded to `guest`.
        // If this ever regresses to `guest`, an authenticated player would
        // keep playing under an anonymous identity without knowing it.
        expect(sessionStore.mode, SessionMode.none);
        expect(sessionStore.token, isNull);
      },
    );

    test(
      'should_clear_the_guest_token_when_a_guest_session_gets_401',
      () async {
        // Arrange — a guest session whose token the backend just rejected.
        await sessionStore.startGuest('stale-guest-token');
        final interceptor = AuthInterceptor(
          sessionStore: sessionStore,
          guestUuid: 'irrelevant-uuid',
          guestDisplayName: 'irrelevant',
        );
        final handler = ErrorInterceptorHandler();
        unawaited(drain(handler));

        // Act — the retry itself will fail (no real backend in this test),
        // but the stale token must be cleared regardless of the outcome.
        interceptor.onError(unauthorizedError(), handler);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(sessionStore.token, isNot('stale-guest-token'));
      },
    );
  });

  group('_ensureToken (via onRequest)', () {
    test(
      'should_never_switch_to_guest_mode_when_authenticated_session_has_no_token',
      () async {
        // Arrange — an authenticated mode with no token is an inconsistent
        // state (should not normally happen) that must never silently
        // resolve to a guest login.
        await box.put('sessionMode', SessionMode.authenticated.name);
        expect(sessionStore.mode, SessionMode.authenticated);
        expect(sessionStore.token, isNull);
        final interceptor = AuthInterceptor(
          sessionStore: sessionStore,
          guestUuid: 'irrelevant-uuid',
          guestDisplayName: 'irrelevant',
        );
        final requestHandler = RequestInterceptorHandler();
        unawaited(drain(requestHandler));
        final requestOptions = RequestOptions(path: '/progress');

        // Act
        interceptor.onRequest(requestOptions, requestHandler);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert — mode must still be `authenticated`, never silently
        // switched to `guest` as a side effect of trying to get a token.
        expect(sessionStore.mode, SessionMode.authenticated);
      },
    );
  });
}
