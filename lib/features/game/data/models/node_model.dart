/// Data model for node coordinates (DTO for serialization).
///
/// This is a simple, serializable representation of a node position.
/// Use [Grid2DNodeId] for domain logic.
class NodeModel {
  final int row;
  final int col;

  const NodeModel({
    required this.row,
    required this.col,
  });

  /// Creates a [NodeModel] from a JSON map.
  factory NodeModel.fromMap(Map<String, dynamic> map) {
    return NodeModel(
      row: map['row'] as int,
      col: map['col'] as int,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'row': row,
      'col': col,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeModel &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'NodeModel(row: $row, col: $col)';
}
