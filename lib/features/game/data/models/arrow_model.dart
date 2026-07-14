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

  final bool isSwitchable;

  const ArrowModel({
    required this.id,
    required this.startNode,
    required this.trajectory,
    this.isSwitchable = false,
  });

  factory ArrowModel.fromJson(Map<String, dynamic> json) {
    return ArrowModel(
      id: json['id'] as String,
      startNode: NodeModel.fromJson(json['startNode'] as Map<String, dynamic>),
      trajectory: ArrowTrajectory.fromJson(json['trajectory'] as Map<String, dynamic>),
      isSwitchable: json['isSwitchable'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startNode': startNode.toJson(),
      'trajectory': trajectory.toJson(),
      'isSwitchable': isSwitchable,
    };
  }

  @override
  List<Object?> get props => [id, startNode, trajectory, isSwitchable];
}
