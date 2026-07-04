import 'package:equatable/equatable.dart';

import 'node_model.dart';

/// Serializable representation of an arrow on the board.
class ArrowModel extends Equatable {
  final String id;
  final List<NodeModel> nodes;
  final String direction;

  const ArrowModel({
    required this.id,
    required this.nodes,
    required this.direction,
  });

  factory ArrowModel.fromJson(Map<String, dynamic> json) {
    return ArrowModel(
      id: json['id'] as String,
      nodes: (json['nodes'] as List<dynamic>)
          .map((node) => NodeModel.fromJson(node as Map<String, dynamic>))
          .toList(),
      direction: json['direction'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nodes': nodes.map((node) => node.toJson()).toList(),
      'direction': direction,
    };
  }

  @override
  List<Object?> get props => [id, nodes, direction];
}
