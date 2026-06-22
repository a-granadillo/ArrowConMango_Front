import 'failure.dart';

/// Un error concreto para manejar fallos generales o excepciones inesperadas.
class GenericFailure extends Failure {
  const GenericFailure(String message) : super(message);
}