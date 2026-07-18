# Tasks: AOP Logging & Error Handling

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~300 |
| 400-line budget risk | Low |
| Chained PRs recommended | No |
| Suggested split | Single PR |
| Delivery strategy | single-pr |
| Chain strategy | pending |

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: single-pr
400-line budget risk: Low

## Phase 1: AOP Infrastructure

- [ ] 1.1 Create `lib/core/aop/app_bloc_observer.dart` extending `BlocObserver` with debug-gated logs.
- [ ] 1.2 Create `lib/core/aop/logging_repository_decorator.dart` generic on `T` using `NoSuchMethodError`-safe forwarding.
- [ ] 1.3 Create `lib/core/aop/error_handling_repository_decorator.dart` generic on `T`, mapping physical-layer exceptions to `Result.error(GenericFailure(...))`.

## Phase 2: Register BLoC Observer

- [ ] 2.1 Import `AppBlocObserver` and `flutter_bloc` in `lib/main.dart`.
- [ ] 2.2 Set `Bloc.observer = AppBlocObserver();` before `setupServiceLocator()`.

## Phase 3: Wire Decorators into Composition Root

- [ ] 3.1 After `sl.init()` in `service_locator.dart`, resolve `IProgressRepository`, `ILevelRepository`, `IPlayerRepository` and `ILeaderboardRepository`.
- [ ] 3.2 Unregister each abstraction and re-register the decorated instance with `ErrorHandlingRepositoryDecorator` inner and `LoggingRepositoryDecorator` outer.

## Phase 4: Tests

- [ ] 4.1 Write `test/core/aop/logging_repository_decorator_test.dart` verifying method invocation, duration log and safe argument logging.
- [ ] 4.2 Write `test/core/aop/error_handling_repository_decorator_test.dart` verifying `HiveError`, `DioException` and `ArgumentError` handling.
- [ ] 4.3 Write `test/core/aop/app_bloc_observer_test.dart` verifying transitions and errors are logged.

## Phase 5: Verification & Documentation

- [ ] 5.1 Run `flutter test` and ensure all tests pass.
- [ ] 5.2 Update `AI_USAGE.md` with a concise entry describing the AOP implementation.
