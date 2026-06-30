/// Data model for app progress (DTO for serialization).
///
/// This is a simple, serializable representation of player progress.
/// Use [AppProgress] for domain logic.
class AppProgressModel {
  final List<int> unlockedLevels;
  final String currentToken;

  const AppProgressModel({
    required this.unlockedLevels,
    required this.currentToken,
  });

  /// Creates an [AppProgressModel] from a JSON map.
  factory AppProgressModel.fromMap(Map<String, dynamic> map) {
    return AppProgressModel(
      unlockedLevels: List<int>.from(map['unlockedLevels'] as List<dynamic>),
      currentToken: map['currentToken'] as String,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'unlockedLevels': unlockedLevels,
      'currentToken': currentToken,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppProgressModel &&
          runtimeType == other.runtimeType &&
          _listEquals(unlockedLevels, other.unlockedLevels) &&
          currentToken == other.currentToken;

  @override
  int get hashCode => unlockedLevels.hashCode ^ currentToken.hashCode;

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'AppProgressModel(unlocked: $unlockedLevels, token: $currentToken)';
}
