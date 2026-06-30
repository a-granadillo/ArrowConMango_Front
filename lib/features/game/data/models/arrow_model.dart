import 'node_model.dart';

/// Data model for arrow entities (DTO for serialization).
///
/// This is a simple, serializable representation of an arrow.
/// Use [ArrowEntity] for domain logic.
class ArrowModel {
  final String id;
  final String direction; // CardinalDirection name
  final List<NodeModel> occupiedNodes;

  const ArrowModel({
    required this.id,
    required this.direction,
    required this.occupiedNodes,
  });

  /// Creates an [ArrowModel] from a JSON map.
  factory ArrowModel.fromMap(Map<String, dynamic> map) {
    return ArrowModel(
      id: map['id'] as String,
      direction: map['direction'] as String,
      occupiedNodes: (map['occupiedNodes'] as List<dynamic>)
          .map((node) => NodeModel.fromMap(node as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'direction': direction,
      'occupiedNodes': occupiedNodes.map((node) => node.toMap()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArrowModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          direction == other.direction &&
          _listEquals(occupiedNodes, other.occupiedNodes);

  @override
  int get hashCode =>
      id.hashCode ^ direction.hashCode ^ occupiedNodes.hashCode;

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'ArrowModel(id: $id, direction: $direction, nodes: ${occupiedNodes.length})';
}
