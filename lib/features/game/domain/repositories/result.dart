import '../errors/failure.dart';

/// Sealed result type for domain operations — replaces `Either<Failure, T>`.
///
/// Uses Dart 3 sealed classes so the compiler enforces exhaustive
/// pattern matching. No external FP library needed.
///
/// Usage:
/// ```dart
/// final result = await repository.loadLevel(1);
/// switch (result) {
///   case Success(:final value):
///     // use value
///   case Error(:final failure):
///     // handle failure
/// }
/// ```
sealed class Result<T> {
  const Result();
}

/// Operation completed successfully with a [value].
class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

/// Operation failed with a domain [failure].
class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
