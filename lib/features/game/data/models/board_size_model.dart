import 'package:equatable/equatable.dart';

/// Serializable representation of a 2D rectangular board size.
class BoardSizeModel extends Equatable {
  final int rows;
  final int cols;

  const BoardSizeModel({required this.rows, required this.cols});

  factory BoardSizeModel.fromJson(Map<String, dynamic> json) {
    return BoardSizeModel(
      rows: json['rows'] as int,
      cols: json['cols'] as int,
    );
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
