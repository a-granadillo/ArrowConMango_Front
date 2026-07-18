// ignore_for_file: prefer_initializing_formals
// Named params are assigned to private fields so the public API stays clean.

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../game/domain/entities/app_progress.dart';
import '../../../game/domain/repositories/i_progress_repository.dart';
import '../../data/remote_auth_data_source.dart';
import '../../data/session_store.dart';
import 'auth_state.dart';

/// Drives registration, login, guest continuation, and sign-out.
///
/// On a successful register/login, [SessionStore] is switched to
/// [SessionMode.authenticated] *before* the local progress is re-saved —
/// [IProgressRepository.saveProgress] fire-and-forget-pushes to the backend,
/// and by then [AuthInterceptor] is already attaching the new account's
/// token, so this one call both migrates the guest's local progress onto the
/// account and lets the server-side idempotent merge (union of completed
/// levels, best score per level, max currentLevel) do the rest — no
/// bespoke merge logic needed on the client.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required RemoteAuthDataSource remoteAuth,
    required SessionStore sessionStore,
    required IProgressRepository progressRepo,
  })  : _remoteAuth = remoteAuth,
        _sessionStore = sessionStore,
        _progressRepo = progressRepo,
        super(const AuthInitial());

  final RemoteAuthDataSource _remoteAuth;
  final SessionStore _sessionStore;
  final IProgressRepository _progressRepo;

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    emit(const AuthLoading());
    try {
      final result = await _remoteAuth.register(
        email: email,
        password: password,
        username: username,
      );
      await _sessionStore.startAuthenticated(result.token);
      await _resetLocalProgress();
      emit(const AuthAuthenticated(progressMigrated: true));
    } on DioException catch (e) {
      emit(AuthFailure(_messageFor(e)));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      final token = await _remoteAuth.login(email: email, password: password);
      await _sessionStore.startAuthenticated(token);
      await _progressRepo.loadProgress();
      emit(const AuthAuthenticated(progressMigrated: true));
    } on DioException catch (e) {
      emit(AuthFailure(_messageFor(e)));
    }
  }

  /// Marks the session as an anonymous guest. The actual guest token is
  /// obtained lazily by [AuthInterceptor] on the next backend request.
  void continueAsGuest() {
    emit(const AuthGuest());
  }

  Future<void> signOut() async {
    await _sessionStore.signOut();
    await _progressRepo.saveProgress(const AppProgress(unlockedLevels: [1], currentLevel: 1));
  }

  Future<void> _resetLocalProgress() async {
    await _progressRepo.saveProgress(const AppProgress(unlockedLevels: [1], currentLevel: 1));
  }

  String _messageFor(DioException e) {
    final status = e.response?.statusCode;
    if (status == 409) return 'Ese correo ya está registrado.';
    if (status == 401) return 'Correo o contraseña incorrectos.';
    if (status == 422) return 'Datos inválidos.';
    return 'No se pudo conectar. Intenta de nuevo.';
  }
}
