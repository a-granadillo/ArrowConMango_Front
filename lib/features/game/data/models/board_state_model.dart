import 'arrow_model.dart';

/// Data model for board state (DTO for serialization).
///
/// This is a simple, serializable representation of the board.
/// Use [BoardState] for domain logic.
class BoardStateModel {
  final List<ArrowModel> arrows;

  const BoardStateModel({
    required this.arrows,
  });

  /// Creates a [BoardStateModel] from a JSON map.
  factory BoardStateModel.fromMap(Map<String, dynamic> map) {
    return BoardStateModel(
      arrows: (map['arrows'] as List<dynamic>)
          .map((arrow) => ArrowModel.fromMap(arrow as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'arrows': arrows.map((arrow) => arrow.toMap()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardStateModel &&
          runtimeType == other.runtimeType &&
          _listEquals(arrows, other.arrows);

  @override
  int get hashCode => arrows.hashCode;

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() => 'BoardStateModel(arrows: ${arrows.length})';
}
