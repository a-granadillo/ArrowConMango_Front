import 'package:equatable/equatable.dart';

/// Base class for all domain-layer failures.
///
/// Uses [Equatable] for value equality so BLoC states can compare
/// failures without reference checks. Implements [Exception] so
/// callers may throw/catch them when needed.
///
/// Subclasses represent specific failure scenarios and carry
/// contextual information (e.g. which arrow ID was not found).
abstract class Failure extends Equatable implements Exception {
  /// Human-readable description of what went wrong.
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => '$runtimeType($message)';
}
