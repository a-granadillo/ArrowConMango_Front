import 'package:equatable/equatable.dart';

/// Serializable representation of a 2D rectangular board size.
class BoardSizeModel extends Equatable {
  final int rows;
  final int cols;

  const BoardSizeModel({required this.rows, required this.cols})
      : assert(rows > 0, 'rows must be positive'),
        assert(cols > 0, 'cols must be positive');

  factory BoardSizeModel.fromJson(Map<String, dynamic> json) {
    final rows = json['rows'] as int;
    final cols = json['cols'] as int;
    
    if (rows <= 0 || cols <= 0) {
      throw ArgumentError('BoardSizeModel requires positive dimensions: rows=$rows, cols=$cols');
    }
    
    return BoardSizeModel(rows: rows, cols: cols);
  }

  Map<String, dynamic> toJson() {
    return {
      'rows': rows,
      'cols': cols,
    };
  }

  @override
  List<Object?> get props => [rows, cols];
}
