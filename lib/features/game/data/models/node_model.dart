import 'package:equatable/equatable.dart';

/// Serializable representation of a 2D grid node.
///
/// Maps to [Grid2DNodeId] in the data layer. This model is
/// intentionally simple (row/col) because the current persistence format
/// only supports 2D rectangular boards.
class NodeModel extends Equatable {
  final int row;
  final int col;

  const NodeModel({
    required this.row,
    required this.col,
  });

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    return NodeModel(
      row: json['row'] as int,
      col: json['col'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'row': row,
      'col': col,
    };
  }

  @override
  List<Object?> get props => [row, col];
}
