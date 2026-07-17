import 'package:equatable/equatable.dart';

/// A one-shot signal that two arrows just collided (one's exit was blocked
/// by the other). Emitted on [GameBloc.arrowCollisions] for the presentation
/// layer to trigger an impact animation on both arrows — separate from
/// [GameState] because it's a transient event, not something that should
/// persist across rebuilds or state comparisons.
class ArrowCollisionEvent extends Equatable {
  const ArrowCollisionEvent({
    required this.movingArrowId,
    required this.blockingArrowId,
  });

  /// ID of the arrow that attempted to exit.
  final String movingArrowId;

  /// ID of the arrow that blocked it.
  final String blockingArrowId;

  @override
  List<Object?> get props => [movingArrowId, blockingArrowId];
}
