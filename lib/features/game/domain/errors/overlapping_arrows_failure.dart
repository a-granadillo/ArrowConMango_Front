import 'failure.dart';

/// Two or more arrows occupy the same node on the board.
///
/// This indicates a malformed level definition — the domain
/// considers overlapping arrows an invalid state.
class OverlappingArrowsFailure extends Failure {
  /// The node key where the overlap was detected.
  final String nodeKey;

  /// IDs of the arrows that share this node.
  final List<String> arrowIds;

  OverlappingArrowsFailure({
    required this.nodeKey,
    required this.arrowIds,
  }) : super(
          'Node "$nodeKey" is occupied by multiple arrows: ${arrowIds.join(", ")}',
        );

  @override
  List<Object?> get props => [message, nodeKey, arrowIds];
}
