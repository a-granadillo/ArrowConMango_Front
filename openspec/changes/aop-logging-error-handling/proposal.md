# Proposal: AOP Logging & Error Handling

## Change Name
aop-logging-error-handling

## Linked Issue
GitHub #14 — AOP - Logging & Error Handling

## Intent
Introduce small, compile-safe Aspect-Oriented Programming (AOP) infrastructure so that logging and centralized error handling become **cross-cutting concerns**, applied via the Decorator pattern and a `BlocObserver`, instead of being scattered across business logic.

## Scope
1. Add a global `AppBlocObserver` that logs BLoC lifecycle events, transitions and errors without modifying any existing BLoC.
2. Add generic repository decorators for:
   - **Logging**: log input arguments, duration and result status of repository calls.
   - **Error handling**: catch unexpected physical-layer exceptions (Hive, Dio) and map them to domain `Failure` objects wrapped in `Result.error`.
3. Wire the decorators into the existing composition root (`service_locator.dart`) so that `IProgressRepository`, `ILevelRepository`, `IPlayerRepository` and `ILeaderboardRepository` instances are transparently wrapped.
4. Register `AppBlocObserver` in `lib/main.dart`.

## Out of Scope
- Network retry policies (already exist in `ApiClient`).
- Analytics / crash reporters such as Firebase Crashlytics.
- Changing repository public signatures or behavior expectations.

## Approach
- **Decorator Pattern** for repository cross-cutting behavior (logging & error handling).
- **BlocObserver** from `flutter_bloc` for presentation-layer lifecycle logging.
- Manual wrapping in `setupServiceLocator()` using `registerSingleton`/`registerLazySingleton` replacement, preserving `injectable` code generation for the concrete implementations.
- Pure Dart logging abstraction to avoid adding new package dependencies; output uses `dart:developer` for structured Debug Console logs.

## Rollback Plan
- Revert the composition-root wrapping lines in `service_locator.dart`.
- Remove the `Bloc.observer = AppBlocObserver();` line in `main.dart`.
- Delete the `lib/core/aop/` directory.
- Existing domain and data layers remain untouched and continue to work.

## Risks
| Risk | Mitigation |
|------|------------|
| Performance overhead on hot paths | Log only at Debug/Profile mode; production logs are no-ops. |
| Sensitive PII in logs | Do not log `Player` tokens or full `AppProgressModel`; log IDs and status only. |
| Decorator wrapping breaks injectable generated registrations | Wrap the resolved instance *after* `sl.init()`, replacing the registration with `unregister`/`registerSingleton`. |
