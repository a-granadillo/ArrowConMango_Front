import 'package:equatable/equatable.dart';

/// Serializable representation of the player's global progress.
class AppProgressModel extends Equatable {
  final int currentLevel;
  final List<int> completedLevels;
  final Map<String, int>? scores;

  const AppProgressModel({
    required this.currentLevel,
    required this.completedLevels,
    this.scores,
  });

  factory AppProgressModel.fromJson(Map<String, dynamic> json) {
    return AppProgressModel(
      currentLevel: json['currentLevel'] as int,
      completedLevels: (json['completedLevels'] as List<dynamic>)
          .map((levelId) => levelId as int)
          .toList(),
      scores: (json['scores'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as int)),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'currentLevel': currentLevel,
      'completedLevels': completedLevels,
    };

    final scoresValue = scores;
    if (scoresValue != null) {
      json['scores'] = scoresValue;
    }

    return json;
  }

  @override
  List<Object?> get props => [currentLevel, completedLevels, scores];
}
