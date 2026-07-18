# Design: AOP Logging & Error Handling

## Design Decisions

### 1. No Reflection / No Code Generation for Aspects
Dart does not support runtime bytecode weaving or dynamic proxies out of the box. We implement AOP with explicit, compile-safe **Decorator classes** that implement the same repository interfaces as their delegates. This keeps type safety and does not require new dependencies.

### 2. Two Decorators, One Composition Pattern
Each repository can be wrapped independently. The recommended order is:
```
LoggingRepositoryDecorator(
  ErrorHandlingRepositoryDecorator(
    ConcreteRepository(),
  ),
)
```
Error handling runs closest to the real repository so that a caught exception is converted to `Result.error` before the logging decorator measures and logs the final result.

### 3. Repository-Agnostic Generic Decorators
Both decorators are generic on the repository interface type `T`. They accept a class instance and are instantiated with explicit type arguments per abstraction:
- `LoggingRepositoryDecorator<IProgressRepository>`
- `ErrorHandlingRepositoryDecorator<ILevelRepository>`

This avoids per-repository boilerplate while preserving static types.

### 4. Production-Safe Logging
All logging methods check `kDebugMode` and early-return on release builds. Logs use `dart:developer` (`log(...)`) so they show in the Flutter DevTools console and can be filtered.

### 5. PII / Token Safety
The logging decorator logs:
- repository type
- method name
- argument runtime types (not values)
- result type (`Success` / `Error`)
- duration in milliseconds
It MUST NOT log full models, player tokens, or raw network payloads.

### 6. BLoC Observer Registration
`AppBlocObserver` extends `BlocObserver` and is registered once in `main.dart` before `runApp`:
```dart
Bloc.observer = AppBlocObserver();
```
It logs create/close, events, transitions and errors, and is also gated behind `kDebugMode`.

## Files to Create
- `lib/core/aop/logging_repository_decorator.dart`
- `lib/core/aop/error_handling_repository_decorator.dart`
- `lib/core/aop/app_bloc_observer.dart`

## Files to Modify
- `lib/main.dart` — register `AppBlocObserver`
- `lib/core/di/service_locator.dart` — wrap repository instances with decorators

## Files to Create for Tests
- `test/core/aop/logging_repository_decorator_test.dart`
- `test/core/aop/error_handling_repository_decorator_test.dart`
- `test/core/aop/app_bloc_observer_test.dart`

## Sequence: Decorated Repository Call
```text
Use Case -> Decorated Repo (logging)
                -> Decorated Repo (error)
                        -> Concrete Repo
                <- Result<T> or exception
          <- Result<T>
```
