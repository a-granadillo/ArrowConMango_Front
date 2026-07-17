import 'dart:io';

import 'package:arrowconmango_front/features/player/data/auth_token_store.dart';
import 'package:arrowconmango_front/features/player/data/session_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late Box<dynamic> box;
  late SessionStore store;
  int boxCounter = 0;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('acm_session');
    Hive.init(dir.path);
    box = await Hive.openBox<dynamic>('session_${boxCounter++}');
    store = SessionStore(box: box, tokenStore: AuthTokenStore(box: box));
  });

  tearDown(() async {
    await box.close();
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('should_default_to_none_when_nothing_persisted', () {
    expect(store.mode, SessionMode.none);
    expect(store.token, isNull);
  });

  test('should_persist_guest_mode_and_token_when_starting_guest', () async {
    await store.startGuest('guest-token');

    expect(store.mode, SessionMode.guest);
    expect(store.token, 'guest-token');
  });

  test('should_persist_authenticated_mode_and_token_when_starting_authenticated', () async {
    await store.startAuthenticated('account-token');

    expect(store.mode, SessionMode.authenticated);
    expect(store.token, 'account-token');
  });

  test('should_clear_token_and_reset_to_none_when_signing_out', () async {
    await store.startAuthenticated('account-token');

    await store.signOut();

    expect(store.mode, SessionMode.none);
    expect(store.token, isNull);
  });

  test('should_notify_listeners_on_every_transition', () async {
    var notifications = 0;
    store.addListener(() => notifications++);

    await store.startGuest('t1');
    await store.startAuthenticated('t2');
    await store.signOut();

    expect(notifications, 3);
  });
}
