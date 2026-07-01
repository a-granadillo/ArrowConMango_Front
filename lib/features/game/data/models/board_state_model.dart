import 'package:equatable/equatable.dart';

import 'arrow_model.dart';

/// Serializable representation of the board state.
class BoardStateModel extends Equatable {
  final List<ArrowModel> arrows;

  const BoardStateModel({
    required this.arrows,
  });

  factory BoardStateModel.fromJson(Map<String, dynamic> json) {
    return BoardStateModel(
      arrows: (json['arrows'] as List<dynamic>)
          .map((arrow) => ArrowModel.fromJson(arrow as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arrows': arrows.map((arrow) => arrow.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [arrows];
}
