import 'package:equatable/equatable.dart';

class BoardSizeModel extends Equatable {
  final int rows;
  final int cols;

  const BoardSizeModel({
    required this.rows,
    required this.cols,
  }) : assert(rows > 0, 'rows must be positive'),
       assert(cols > 0, 'cols must be positive');

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
