import 'failure.dart';

/// Attempted to operate on an arrow that does not exist on the board.
///
/// Typically raised when a use case references a stale arrow ID
/// after the board state has changed (e.g. after an undo or exit).
class ArrowNotFoundFailure extends Failure {
  /// The arrow ID that was not found in the current [BoardState].
  final String arrowId;

  const ArrowNotFoundFailure({required this.arrowId})
      : super('Arrow "$arrowId" not found on the board');

  @override
  List<Object?> get props => [message, arrowId];
}
