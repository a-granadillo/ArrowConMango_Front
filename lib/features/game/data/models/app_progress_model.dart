import 'package:equatable/equatable.dart';

import 'level_best_model.dart';

/// Serializable representation of the player's global progress.
class AppProgressModel extends Equatable {
  final int currentLevel;
  final List<int> completedLevels;
  final Map<int, LevelBestModel>? best;

  const AppProgressModel({
    required this.currentLevel,
    required this.completedLevels,
    this.best,
  });

  factory AppProgressModel.fromJson(Map<String, dynamic> json) {
    return AppProgressModel(
      currentLevel: json['currentLevel'] as int,
      completedLevels: (json['completedLevels'] as List<dynamic>)
          .map((levelId) => levelId as int)
          .toList(),
      best: (json['best'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          int.parse(key),
          LevelBestModel.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'currentLevel': currentLevel,
      'completedLevels': completedLevels,
    };

    final bestValue = best;
    if (bestValue != null) {
      json['best'] = bestValue.map(
        (key, value) => MapEntry(key.toString(), value.toJson()),
      );
    }

    return json;
  }

  @override
  List<Object?> get props => [currentLevel, completedLevels, best];
}
