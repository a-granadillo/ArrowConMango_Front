import 'package:equatable/equatable.dart';

import 'arrow_trajectory.dart';
import 'node_model.dart';

/// Serializable representation of an arrow on the board.
///
/// An arrow is defined by:
/// - [id]: Unique identifier
/// - [startNode]: The starting position (tail of the arrow)
/// - [trajectory]: The path the arrow follows (sequence of segments)
///
/// The trajectory can include multiple segments with 90° turns, allowing
/// for complex L-shaped or zigzag paths.
class ArrowModel extends Equatable {
  final String id;
  final NodeModel startNode;
  final ArrowTrajectory trajectory;

  const ArrowModel({
    required this.id,
    required this.startNode,
    required this.trajectory,
  });

  factory ArrowModel.fromJson(Map<String, dynamic> json) {
    return ArrowModel(
      id: json['id'] as String,
      startNode: NodeModel.fromJson(json['startNode'] as Map<String, dynamic>),
      trajectory: ArrowTrajectory.fromJson(json['trajectory'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startNode': startNode.toJson(),
      'trajectory': trajectory.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, startNode, trajectory];
}
