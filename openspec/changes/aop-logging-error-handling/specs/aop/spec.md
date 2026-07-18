# Specs: AOP Logging & Error Handling

## ADDED Requirements

### REQ-001: Bloc Lifecycle Logging
The application MUST observe and log all BLoC lifecycle events (create, event, transition, error, close) through a single `AppBlocObserver` registered before `runApp`.

**Scenario 1.1: Log BLoC transitions in debug mode**
Given the app is running in debug mode
When any BLoC emits a new state
Then the observer logs the BLoC runtime type, the triggering event, the previous state and the next state.

**Scenario 1.2: Suppress BLoC logs in release mode**
Given the app is built in release mode
When any BLoC emits a new state
Then no observability log is emitted to the developer console.

**Scenario 1.3: Log BLoC errors centrally**
Given a BLoC throws an unhandled exception inside an event handler
Then the observer captures the error and stack trace without rethrowing or altering normal error propagation.

---

### REQ-002: Repository Logging Decorator
The application MUST provide a `LoggingRepositoryDecorator<T>` that wraps any repository implementing an interface `T` and logs call entry, arguments (safe), duration and result status.

**Scenario 2.1: Log repository call and duration**
Given a repository wrapped with `LoggingRepositoryDecorator`
When a method is awaited
Then a log entry contains the method name, elapsed milliseconds and whether the result was `Success` or `Error`.

**Scenario 2.2: Do not log sensitive values**
Given a repository method receives a domain object with sensitive fields
Then the decorator MUST only log the runtime type, not the full `toString()` of the payload.

---

### REQ-003: Repository Error-Handling Decorator
The application MUST provide a `ErrorHandlingRepositoryDecorator<T>` that catches synchronous and asynchronous exceptions from the wrapped repository and returns `Result.error(GenericFailure(...))`.

**Scenario 3.1: Convert Hive/IO exception to domain failure**
Given a local repository throws a `HiveError` or `FileSystemException`
When `ErrorHandlingRepositoryDecorator` wraps that repository
Then the caller receives a `Result.error` containing a `GenericFailure` instead of an unhandled exception.

**Scenario 3.2: Convert Dio/network exception to domain failure**
Given a remote repository throws a `DioException`
When `ErrorHandlingRepositoryDecorator` wraps that repository
Then the caller receives a `Result.error` containing a `GenericFailure` with a normalized message.

**Scenario 3.3: Rethrow unsupported errors**
Given a non-infrastructure exception (e.g., `ArgumentError`) is thrown
When `ErrorHandlingRepositoryDecorator` intercepts it
Then it logs the error and rethrows it so programming mistakes are not silently swallowed.

---

### REQ-004: Composition-Root Wiring
The decorators MUST be applied transparently to the existing repository abstraction instances in `setupServiceLocator()` without changing the signatures of use cases or BLoCs.

**Scenario 4.1: Existing use cases receive decorated repositories**
Given `setupServiceLocator()` has completed
When a use case resolves `IProgressRepository`
Then it receives the repository wrapped first by error handling and then by logging.

**Scenario 4.2: BLoCs use the same resolved instances**
Given `GameBloc` resolves `LoadLevelUseCase`
When it calls the use case
Then the underlying repository is the decorated one, and BLoC observer logs the flow.

---

## MODIFIED Requirements
None.

## REMOVED Requirements
None.
