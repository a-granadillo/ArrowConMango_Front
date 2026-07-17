import 'dart:io';

import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_progress_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/player/data/auth_token_store.dart';
import 'package:arrowconmango_front/features/player/data/remote_auth_data_source.dart';
import 'package:arrowconmango_front/features/player/data/session_store.dart';
import 'package:arrowconmango_front/features/player/presentation/bloc/auth_cubit.dart';
import 'package:arrowconmango_front/features/player/presentation/bloc/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteAuthDataSource extends Mock implements RemoteAuthDataSource {}

class _MockProgressRepository extends Mock implements IProgressRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const AppProgress());
  });

  late Directory dir;
  late Box<dynamic> box;
  late SessionStore sessionStore;
  late _MockRemoteAuthDataSource remoteAuth;
  late _MockProgressRepository progressRepo;
  int boxCounter = 0;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('acm_auth_cubit');
    Hive.init(dir.path);
    box = await Hive.openBox<dynamic>('auth_cubit_${boxCounter++}');
    sessionStore = SessionStore(box: box, tokenStore: AuthTokenStore(box: box));
    remoteAuth = _MockRemoteAuthDataSource();
    progressRepo = _MockProgressRepository();
    when(() => progressRepo.loadProgress())
        .thenAnswer((_) async => const Success(AppProgress()));
    when(() => progressRepo.saveProgress(any()))
        .thenAnswer((_) async => const Success<void>(null));
  });

  tearDown(() async {
    await box.close();
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  AuthCubit buildCubit() => AuthCubit(
        remoteAuth: remoteAuth,
        sessionStore: sessionStore,
        progressRepo: progressRepo,
      );

  group('register', () {
    blocTest<AuthCubit, AuthState>(
      'emits loading then authenticated, migrates progress, and starts an authenticated session',
      build: () {
        when(() => remoteAuth.register(
              email: any(named: 'email'),
              password: any(named: 'password'),
              username: any(named: 'username'),
            )).thenAnswer(
          (_) async => const AuthResult(token: 'new-token', username: 'Ana'),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.register(
        email: 'ana@test.com',
        password: 'secret123',
        username: 'Ana',
      ),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(),
        const AuthAuthenticated(progressMigrated: true),
      ],
      verify: (_) {
        expect(sessionStore.mode, SessionMode.authenticated);
        expect(sessionStore.token, 'new-token');
        verify(() => progressRepo.loadProgress()).called(1);
        verify(() => progressRepo.saveProgress(any())).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits failure and does not touch the session when the email is already taken',
      build: () {
        when(() => remoteAuth.register(
              email: any(named: 'email'),
              password: any(named: 'password'),
              username: any(named: 'username'),
            )).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/auth/register'),
            response: Response(
              requestOptions: RequestOptions(path: '/auth/register'),
              statusCode: 409,
            ),
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.register(
        email: 'taken@test.com',
        password: 'secret123',
        username: 'Dup',
      ),
      expect: () => [
        const AuthLoading(),
        isA<AuthFailure>(),
      ],
      verify: (_) {
        expect(sessionStore.mode, SessionMode.none);
        verifyNever(() => progressRepo.saveProgress(any()));
      },
    );
  });

  group('login', () {
    blocTest<AuthCubit, AuthState>(
      'emits loading then authenticated and migrates progress',
      build: () {
        when(() => remoteAuth.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => 'login-token');
        return buildCubit();
      },
      act: (cubit) =>
          cubit.login(email: 'ana@test.com', password: 'secret123'),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(),
        const AuthAuthenticated(progressMigrated: true),
      ],
      verify: (_) {
        expect(sessionStore.mode, SessionMode.authenticated);
        expect(sessionStore.token, 'login-token');
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits failure when credentials are wrong',
      build: () {
        when(() => remoteAuth.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/auth/login'),
            response: Response(
              requestOptions: RequestOptions(path: '/auth/login'),
              statusCode: 401,
            ),
          ),
        );
        return buildCubit();
      },
      act: (cubit) =>
          cubit.login(email: 'ana@test.com', password: 'wrong'),
      expect: () => [
        const AuthLoading(),
        isA<AuthFailure>(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'does not fail the login flow when progress migration fails',
      build: () {
        when(() => remoteAuth.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => 'login-token');
        when(() => progressRepo.loadProgress()).thenAnswer(
          (_) async => const Error<AppProgress>(GenericFailure('offline')),
        );
        return buildCubit();
      },
      act: (cubit) =>
          cubit.login(email: 'ana@test.com', password: 'secret123'),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(),
        const AuthAuthenticated(progressMigrated: true),
      ],
      verify: (_) {
        verifyNever(() => progressRepo.saveProgress(any()));
      },
    );
  });

  group('continueAsGuest', () {
    blocTest<AuthCubit, AuthState>(
      'emits guest without touching SessionStore (the interceptor logs in lazily)',
      build: buildCubit,
      act: (cubit) => cubit.continueAsGuest(),
      expect: () => [const AuthGuest()],
      verify: (_) {
        expect(sessionStore.mode, SessionMode.none);
      },
    );
  });

  group('signOut', () {
    test('should_reset_the_session_to_none', () async {
      await sessionStore.startAuthenticated('t');
      final cubit = buildCubit();

      await cubit.signOut();

      expect(sessionStore.mode, SessionMode.none);
      await cubit.close();
    });
  });
}
